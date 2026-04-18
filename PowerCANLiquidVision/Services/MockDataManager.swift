import Foundation
import Combine

final class MockDataManager: DataProvider {
    private let obdDataSubject = CurrentValueSubject<OBDData, Never>(OBDData())
    private let connectionStateSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    private var timer: Timer?
    private var elapsed: TimeInterval = 0

    var obdDataPublisher: AnyPublisher<OBDData, Never> {
        obdDataSubject.eraseToAnyPublisher()
    }

    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    var currentData: OBDData { obdDataSubject.value }
    var connectionState: ConnectionState { connectionStateSubject.value }

    func start() {
        elapsed = 0
        connectionStateSubject.send(.simulating)

        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        connectionStateSubject.send(.disconnected)
        obdDataSubject.send(OBDData())
    }

    private func tick() {
        elapsed += 0.1

        var data = OBDData()

        let rpmBase = 2800.0
        let rpmAmplitude = 2200.0
        let rpmCycle = sin(elapsed * 0.4) * sin(elapsed * 0.15)
        data.rpm = max(800, rpmBase + rpmAmplitude * rpmCycle + Double.random(in: -30...30))

        let accelPhase = min(elapsed / 25.0, 1.0)
        let speedOscillation = sin(elapsed * 0.2) * 20.0
        data.speed = max(0, 130.0 * accelPhase + speedOscillation + Double.random(in: -2...2))
        data.speed = min(data.speed, 220)

        let warmup = min(elapsed / 60.0, 1.0)
        data.coolantTemp = 20 + 72 * warmup + sin(elapsed * 0.05) * 3 + Double.random(in: -0.5...0.5)
        data.coolantTemp = min(data.coolantTemp, 110)

        data.shortTermFuelTrim = sin(elapsed * 0.6) * 8.0 + Double.random(in: -1...1)
        data.longTermFuelTrim = sin(elapsed * 0.1) * 4.0 + Double.random(in: -0.5...0.5)

        data.intakeTemp = 25 + sin(elapsed * 0.08) * 10 + Double.random(in: -1...1)
        data.engineLoad = max(0, min(100, 40 + 30 * sin(elapsed * 0.3) + Double.random(in: -3...3)))
        data.throttlePosition = max(0, min(100, 30 + 40 * sin(elapsed * 0.5) + Double.random(in: -2...2)))
        data.mafRate = max(0, 8 + 6 * sin(elapsed * 0.35) + Double.random(in: -0.5...0.5))

        let instantConsumption = data.speed > 5
            ? (data.mafRate * 3600) / (14.7 * 0.745 * data.speed) * 100
            : 0
        data.fuelConsumptionRate = min(instantConsumption, 30)

        obdDataSubject.send(data)
    }
}
