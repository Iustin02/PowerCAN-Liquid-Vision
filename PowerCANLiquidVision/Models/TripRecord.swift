import Foundation
import SwiftData
import CoreLocation

@Model
final class TripRecord {
    var id: UUID
    var startDate: Date
    var endDate: Date?
    var routePoints: [RoutePoint]
    var maxSpeed: Double
    var avgSpeed: Double
    var maxRPM: Double
    var avgFuelConsumption: Double
    var distanceKm: Double
    var isActive: Bool

    init(
        startDate: Date = .now,
        routePoints: [RoutePoint] = [],
        maxSpeed: Double = 0,
        avgSpeed: Double = 0,
        maxRPM: Double = 0,
        avgFuelConsumption: Double = 0,
        distanceKm: Double = 0
    ) {
        self.id = UUID()
        self.startDate = startDate
        self.routePoints = routePoints
        self.maxSpeed = maxSpeed
        self.avgSpeed = avgSpeed
        self.maxRPM = maxRPM
        self.avgFuelConsumption = avgFuelConsumption
        self.distanceKm = distanceKm
        self.isActive = true
    }

    var durationFormatted: String {
        guard let end = endDate else {
            let elapsed = Date.now.timeIntervalSince(startDate)
            return Self.formatDuration(elapsed)
        }
        return Self.formatDuration(end.timeIntervalSince(startDate))
    }

    private static func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes) min"
    }
}

struct RoutePoint: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    let speed: Double
    let rpm: Double
    let timestamp: Date

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var speedNormalized: Double {
        min(speed / 160.0, 1.0)
    }
}
