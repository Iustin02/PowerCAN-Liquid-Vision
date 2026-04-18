import Foundation
import Combine
import SwiftData
import CoreLocation

@MainActor
final class OBDViewModel: ObservableObject {
    @Published var obdData = OBDData()
    @Published var connectionState: ConnectionState = .disconnected
    @Published var dataMode: DataMode = .simulated {
        didSet { switchProvider() }
    }
    @Published var isTripActive = false
    @Published var dtcCodes: [DiagnosticTroubleCode] = []

    private var provider: DataProvider
    private let mockProvider = MockDataManager()
    private let bleProvider = BLEManager()
    private var cancellables = Set<AnyCancellable>()

    private var tripStartDate: Date?
    private var tripSpeedSamples: [Double] = []
    private var tripMaxSpeed: Double = 0
    private var tripMaxRPM: Double = 0
    private var tripRoutePoints: [RoutePoint] = []

    let locationManager = LocationManager()

    init() {
        self.provider = mockProvider
        bindProvider()
    }

    private func bindProvider() {
        cancellables.removeAll()

        provider.obdDataPublisher
            .receive(on: RunLoop.main)
            .assign(to: &$obdData)

        provider.connectionStatePublisher
            .receive(on: RunLoop.main)
            .assign(to: &$connectionState)
    }

    private func switchProvider() {
        provider.stop()
        provider = (dataMode == .simulated) ? mockProvider : bleProvider
        bindProvider()
        provider.start()
    }

    func startSession() {
        provider.start()
    }

    func stopSession() {
        provider.stop()
    }

    func startTrip(context: ModelContext) {
        tripStartDate = .now
        tripSpeedSamples = []
        tripMaxSpeed = 0
        tripMaxRPM = 0
        tripRoutePoints = []
        isTripActive = true

        locationManager.requestPermission()
        locationManager.startTracking()

        startTripLogging(context: context)
    }

    private func startTripLogging(context: ModelContext) {
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isTripActive else { return }
                self.recordTripPoint()
            }
            .store(in: &cancellables)
    }

    private func recordTripPoint() {
        let data = obdData
        tripSpeedSamples.append(data.speed)
        tripMaxSpeed = max(tripMaxSpeed, data.speed)
        tripMaxRPM = max(tripMaxRPM, data.rpm)

        if let location = locationManager.currentLocation {
            let point = RoutePoint(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude,
                speed: data.speed,
                rpm: data.rpm,
                timestamp: .now
            )
            tripRoutePoints.append(point)
        }
    }

    func scanDTCs() {
        if dataMode == .simulated {
            dtcCodes = MockDTCGenerator.generate()
        }
    }

    func clearDTCs() {
        dtcCodes.removeAll()
    }

    func endTrip(context: ModelContext) {
        isTripActive = false
        locationManager.stopTracking()

        let avgSpeed = tripSpeedSamples.isEmpty ? 0 : tripSpeedSamples.reduce(0, +) / Double(tripSpeedSamples.count)

        var distance = 0.0
        for i in 1..<tripRoutePoints.count {
            let prev = CLLocation(latitude: tripRoutePoints[i-1].latitude, longitude: tripRoutePoints[i-1].longitude)
            let curr = CLLocation(latitude: tripRoutePoints[i].latitude, longitude: tripRoutePoints[i].longitude)
            distance += curr.distance(from: prev)
        }

        let trip = TripRecord(
            startDate: tripStartDate ?? .now,
            routePoints: tripRoutePoints,
            maxSpeed: tripMaxSpeed,
            avgSpeed: avgSpeed,
            maxRPM: tripMaxRPM,
            avgFuelConsumption: obdData.fuelConsumptionRate,
            distanceKm: distance / 1000.0
        )
        trip.endDate = .now
        trip.isActive = false
        context.insert(trip)
        try? context.save()
    }
}
