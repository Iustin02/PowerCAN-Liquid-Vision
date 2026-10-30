import Foundation

struct DiagnosticTroubleCode: Identifiable, Equatable {
    let id = UUID()
    let code: String
    let category: DTCCategory
    let description: String
    let severity: DTCSeverity
    let timestamp: Date

    var displayCode: String { code }
}

enum DTCCategory: String, CaseIterable {
    case powertrain = "Powertrain"
    case chassis = "Chassis"
    case body = "Body"
    case network = "Network"

    var prefix: String {
        switch self {
        case .powertrain: return "P"
        case .chassis: return "C"
        case .body: return "B"
        case .network: return "U"
        }
    }

    var color: String {
        switch self {
        case .powertrain: return "neonRed"
        case .chassis: return "neonOrange"
        case .body: return "neonCyan"
        case .network: return "neonBlue"
        }
    }
}

enum DTCSeverity: String {
    case critical = "Critical"
    case warning = "Warning"
    case info = "Info"
}

enum DTCDecoder {
    static func decode(byte1: UInt8, byte2: UInt8) -> String {
        let prefixes = ["P", "C", "B", "U"]
        let prefix = prefixes[Int((byte1 >> 6) & 0x03)]
        let digit2 = (byte1 >> 4) & 0x03
        let digit3 = byte1 & 0x0F
        let digit4 = (byte2 >> 4) & 0x0F
        let digit5 = byte2 & 0x0F
        return "\(prefix)\(digit2)\(digit3)\(String(format: "%X", digit4))\(String(format: "%X", digit5))"
    }

    static func category(for code: String) -> DTCCategory {
        guard let first = code.first else { return .powertrain }
        switch first {
        case "P": return .powertrain
        case "C": return .chassis
        case "B": return .body
        case "U": return .network
        default: return .powertrain
        }
    }

    static func severity(for code: String) -> DTCSeverity {
        guard code.count >= 2 else { return .info }
        let secondChar = code[code.index(code.startIndex, offsetBy: 1)]
        if secondChar == "0" { return .critical }
        if secondChar == "1" { return .warning }
        return .info
    }
}

enum DTCDatabase {
    static let descriptions: [String: String] = [
        "P0100": "Mass Air Flow Circuit Malfunction",
        "P0101": "Mass Air Flow Circuit Range/Performance",
        "P0102": "Mass Air Flow Circuit Low Input",
        "P0103": "Mass Air Flow Circuit High Input",
        "P0106": "MAP/BARO Pressure Circuit Range/Performance",
        "P0107": "MAP/BARO Pressure Circuit Low Input",
        "P0110": "Intake Air Temperature Circuit Malfunction",
        "P0115": "Engine Coolant Temp Circuit Malfunction",
        "P0116": "Engine Coolant Temp Circuit Range/Performance",
        "P0117": "Engine Coolant Temp Circuit Low Input",
        "P0118": "Engine Coolant Temp Circuit High Input",
        "P0120": "Throttle Position Sensor Circuit Malfunction",
        "P0121": "Throttle Position Sensor Range/Performance",
        "P0125": "Insufficient Coolant Temp for Fuel Control",
        "P0128": "Coolant Thermostat Below Operating Temp",
        "P0130": "O2 Sensor Circuit Malfunction (Bank 1, Sensor 1)",
        "P0131": "O2 Sensor Circuit Low Voltage (B1S1)",
        "P0133": "O2 Sensor Circuit Slow Response (B1S2)",
        "P0135": "O2 Sensor Heater Circuit Malfunction (B1S1)",
        "P0170": "Fuel Trim Malfunction (Bank 1)",
        "P0171": "System Too Lean (Bank 1)",
        "P0172": "System Too Rich (Bank 1)",
        "P0174": "System Too Lean (Bank 2)",
        "P0175": "System Too Rich (Bank 2)",
        "P0200": "Injector Circuit Malfunction",
        "P0217": "Engine Overtemp Condition",
        "P0230": "Fuel Pump Primary Circuit Malfunction",
        "P0300": "Random/Multiple Cylinder Misfire Detected",
        "P0301": "Cylinder 1 Misfire Detected",
        "P0302": "Cylinder 2 Misfire Detected",
        "P0303": "Cylinder 3 Misfire Detected",
        "P0304": "Cylinder 4 Misfire Detected",
        "P0325": "Knock Sensor 1 Circuit Malfunction",
        "P0335": "Crankshaft Position Sensor Circuit Malfunction",
        "P0340": "Camshaft Position Sensor Circuit Malfunction",
        "P0401": "EGR Flow Insufficient Detected",
        "P0420": "Catalyst System Efficiency Below Threshold (B1)",
        "P0430": "Catalyst System Efficiency Below Threshold (B2)",
        "P0440": "Evaporative Emission System Malfunction",
        "P0442": "EVAP System Leak Detected (Small Leak)",
        "P0446": "EVAP Vent System Performance",
        "P0455": "EVAP System Leak Detected (Large Leak)",
        "P0500": "Vehicle Speed Sensor Malfunction",
        "P0505": "Idle Control System Malfunction",
        "P0507": "Idle Control System RPM Higher Than Expected",
        "P0562": "System Voltage Low",
        "P0563": "System Voltage High",
        "P0600": "Serial Communication Link Malfunction",
        "P0700": "Transmission Control System Malfunction",
        "P0715": "Input/Turbine Speed Sensor Circuit Malfunction",
        "P0720": "Output Speed Sensor Circuit Malfunction",
        "C0035": "Left Front Wheel Speed Circuit Malfunction",
        "C0040": "Right Front Wheel Speed Circuit Malfunction",
        "C0045": "Left Rear Wheel Speed Circuit Malfunction",
        "C0050": "Right Rear Wheel Speed Circuit Malfunction",
        "C0060": "Left Front ABS Solenoid Circuit Malfunction",
        "C0065": "Right Front ABS Solenoid Circuit Malfunction",
        "C0550": "ECU Performance (Stability Control)",
        "B0001": "Driver Frontal Stage 1 Deployment Control",
        "B0010": "Passenger Frontal Stage 1 Deployment Control",
        "B0092": "Left Side Airbag Deployment Control",
        "B1000": "ECU Malfunction (Body Control Module)",
        "U0001": "High Speed CAN Communication Bus",
        "U0100": "Lost Communication with ECM/PCM",
        "U0101": "Lost Communication with TCM",
        "U0121": "Lost Communication with ABS Module",
        "U0140": "Lost Communication with BCM",
        "U0155": "Lost Communication with Instrument Cluster",
    ]

    static func describe(_ code: String) -> String {
        descriptions[code] ?? "Unknown fault — check service manual"
    }
}
