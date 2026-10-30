import Foundation
import Combine
import Network

/// Transport ELM327 peste TCP catre bridge-ul Wi-Fi ESP32 (implicit 192.168.4.1:35000).
/// Implementarea Bluetooth LE initiala este pastrata in tag-ul git `v1.0.0-ble`.
final class WiFiOBDManager: DataProvider {
    private let obdDataSubject = CurrentValueSubject<OBDData, Never>(OBDData())
    private let connectionStateSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)

    private let queue = DispatchQueue(label: "com.powercan.wifi-obd", qos: .userInitiated)

    private var connection: NWConnection?
    private var pollingTask: Task<Void, Never>?
    private var reconnectTask: Task<Void, Never>?
    private var responseBuffer = ""
    private var tickCount = 0
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5
    private var shouldReconnect = false

    private var host: String
    private var port: UInt16

    private let handshakeSequence = ["ATZ\r", "ATE0\r", "ATL1\r", "ATSP0\r"]

    init(host: String = "192.168.4.1", port: UInt16 = 35000) {
        self.host = host
        self.port = port
    }

    var obdDataPublisher: AnyPublisher<OBDData, Never> {
        obdDataSubject.eraseToAnyPublisher()
    }

    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    var currentData: OBDData { obdDataSubject.value }
    var connectionState: ConnectionState { connectionStateSubject.value }

    func updateEndpoint(host: String, port: UInt16) {
        self.host = host
        self.port = port

        guard shouldReconnect else { return }
        reconnectTask?.cancel()
        pollingTask?.cancel()
        connection?.cancel()
        start()
    }

    func start() {
        guard NWEndpoint.Port(rawValue: port) != nil else {
            connectionStateSubject.send(.error)
            return
        }

        shouldReconnect = true
        reconnectTask?.cancel()
        pollingTask?.cancel()
        responseBuffer = ""

        connectionStateSubject.send(.connecting)
        let nwPort = NWEndpoint.Port(rawValue: port)!
        let newConnection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
        connection = newConnection

        newConnection.stateUpdateHandler = { [weak self] state in
            guard let self else { return }
            switch state {
            case .ready:
                self.reconnectAttempts = 0
                Task { await self.runHandshake() }
            case .failed, .cancelled:
                self.pollingTask?.cancel()
                self.pollingTask = nil
                self.attemptReconnect()
            default:
                break
            }
        }

        startReceiving()
        newConnection.start(queue: queue)
    }

    func stop() {
        shouldReconnect = false
        reconnectTask?.cancel()
        reconnectTask = nil
        pollingTask?.cancel()
        pollingTask = nil
        connection?.cancel()
        connection = nil
        connectionStateSubject.send(.disconnected)
    }

    private func runHandshake() async {
        connectionStateSubject.send(.initializing)
        for command in handshakeSequence {
            sendCommand(command)
            try? await Task.sleep(for: .milliseconds(500))
        }
        connectionStateSubject.send(.connected)
        startPolling()
    }

    private func startPolling() {
        tickCount = 0
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.sendCommand("010C\r")
                try? await Task.sleep(for: .milliseconds(120))
                self.sendCommand("010D\r")
                try? await Task.sleep(for: .milliseconds(120))

                if self.tickCount % 3 == 0 {
                    self.sendCommand("0105\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("0104\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("0106\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("0107\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("010F\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("0110\r")
                    try? await Task.sleep(for: .milliseconds(120))
                    self.sendCommand("0111\r")
                    try? await Task.sleep(for: .milliseconds(120))
                }

                self.tickCount += 1
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func startReceiving() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 512) { [weak self] data, _, isComplete, error in
            guard let self else { return }

            if let data, !data.isEmpty, let response = String(data: data, encoding: .ascii) {
                self.responseBuffer += response
                self.consumeBufferedFrames()
            }

            if isComplete || error != nil {
                self.attemptReconnect()
                return
            }

            self.startReceiving()
        }
    }

    private func consumeBufferedFrames() {
        while let endIndex = responseBuffer.firstIndex(of: ">") {
            let frame = String(responseBuffer[..<endIndex])
            parseResponse(frame)
            responseBuffer.removeSubrange(responseBuffer.startIndex...endIndex)
        }
    }

    private func sendCommand(_ command: String) {
        guard let data = command.data(using: .ascii) else { return }
        connection?.send(content: data, completion: .contentProcessed { _ in })
    }

    private func parseResponse(_ raw: String) {
        let normalized = raw.replacingOccurrences(of: "\r", with: "\n")
        let lines = normalized.components(separatedBy: "\n")

        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")
                .uppercased()

            guard cleaned.count >= 4, cleaned.hasPrefix("41") else { continue }

            let pid = String(cleaned.dropFirst(2).prefix(2))
            let bytesHex = String(cleaned.dropFirst(4))

            var data = obdDataSubject.value
            switch pid {
            case "0C":
                if let a = hexByte(bytesHex, at: 0), let b = hexByte(bytesHex, at: 1) {
                    data.rpm = Double((256 * Int(a)) + Int(b)) / 4.0
                }
            case "0D":
                if let a = hexByte(bytesHex, at: 0) {
                    data.speed = Double(a)
                }
            case "05":
                if let a = hexByte(bytesHex, at: 0) {
                    data.coolantTemp = Double(a) - 40
                }
            case "04":
                if let a = hexByte(bytesHex, at: 0) {
                    data.engineLoad = Double(a) * (100.0 / 255.0)
                }
            case "06":
                if let a = hexByte(bytesHex, at: 0) {
                    data.shortTermFuelTrim = (Double(a) - 128) * (100.0 / 128.0)
                }
            case "07":
                if let a = hexByte(bytesHex, at: 0) {
                    data.longTermFuelTrim = (Double(a) - 128) * (100.0 / 128.0)
                }
            case "0F":
                if let a = hexByte(bytesHex, at: 0) {
                    data.intakeTemp = Double(a) - 40
                }
            case "10":
                if let a = hexByte(bytesHex, at: 0), let b = hexByte(bytesHex, at: 1) {
                    data.mafRate = Double((256 * Int(a)) + Int(b)) / 100.0
                }
            case "11":
                if let a = hexByte(bytesHex, at: 0) {
                    data.throttlePosition = Double(a) * (100.0 / 255.0)
                }
            default:
                break
            }

            if data.speed > 5 {
                let instantConsumption = (data.mafRate * 3600.0) / (14.7 * 745.0 * data.speed) * 100.0
                data.fuelConsumptionRate = min(max(instantConsumption, 0), 40)
            } else {
                data.fuelConsumptionRate = 0
            }

            obdDataSubject.send(data)
        }
    }

    private func hexByte(_ hex: String, at index: Int) -> UInt8? {
        let start = hex.index(hex.startIndex, offsetBy: index * 2, limitedBy: hex.endIndex) ?? hex.endIndex
        let end = hex.index(start, offsetBy: 2, limitedBy: hex.endIndex) ?? hex.endIndex
        guard start < hex.endIndex else { return nil }
        return UInt8(String(hex[start..<end]), radix: 16)
    }

    private func attemptReconnect() {
        guard shouldReconnect else { return }
        guard reconnectAttempts < maxReconnectAttempts else {
            connectionStateSubject.send(.error)
            return
        }

        reconnectAttempts += 1
        let delay = min(pow(2.0, Double(reconnectAttempts)), 30)
        reconnectTask?.cancel()
        reconnectTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(delay))
            guard let self, self.shouldReconnect else { return }
            self.start()
        }
    }
}
