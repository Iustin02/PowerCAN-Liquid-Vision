import Foundation

struct OBDData: Equatable, Sendable {
    var rpm: Double = 0
    var speed: Double = 0
    var coolantTemp: Double = 20
    var shortTermFuelTrim: Double = 0
    var longTermFuelTrim: Double = 0
    var intakeTemp: Double = 20
    var engineLoad: Double = 0
    var throttlePosition: Double = 0
    var mafRate: Double = 0
    var fuelConsumptionRate: Double = 0

    var rpmNormalized: Double {
        min(rpm / 7000.0, 1.0)
    }

    var speedNormalized: Double {
        min(speed / 260.0, 1.0)
    }

    var coolantNormalized: Double {
        min(max((coolantTemp - 20) / 100.0, 0), 1.0)
    }

    var heatLevel: Double {
        let rpmWeight = 0.4
        let speedWeight = 0.3
        let coolantWeight = 0.3
        return rpmWeight * rpmNormalized + speedWeight * speedNormalized + coolantWeight * coolantNormalized
    }
}

enum ConnectionState: String, Sendable {
    case disconnected = "Disconnected"
    case scanning = "Scanning..."
    case connecting = "Connecting..."
    case initializing = "Initializing ELM327..."
    case connected = "Connected"
    case simulating = "Simulation Mode"
    case error = "Connection Error"
}

enum DataMode: String, CaseIterable, Sendable {
    case simulated = "Simulated Data"
    case liveOBD = "Live OBD (Wi-Fi)"
}
