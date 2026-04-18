import Foundation
import CoreBluetooth
import Combine

final class BLEManager: NSObject, DataProvider {
    private let obdDataSubject = CurrentValueSubject<OBDData, Never>(OBDData())
    private let connectionStateSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)

    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var writeCharacteristic: CBCharacteristic?
    private var responseBuffer = ""
    private var pollingTask: Task<Void, Never>?
    private var tickCount = 0
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 5

    private let serviceUUIDs = [
        CBUUID(string: "FFF0"),
        CBUUID(string: "FFE0")
    ]
    private let characteristicUUIDs = [
        CBUUID(string: "FFF1"),
        CBUUID(string: "FFE1")
    ]

    private let handshakeSequence = ["ATZ\r", "ATE0\r", "ATL1\r", "ATSP0\r"]

    var obdDataPublisher: AnyPublisher<OBDData, Never> {
        obdDataSubject.eraseToAnyPublisher()
    }

    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    var currentData: OBDData { obdDataSubject.value }
    var connectionState: ConnectionState { connectionStateSubject.value }

    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self,
            queue: .global(qos: .userInitiated),
            options: [CBCentralManagerOptionRestoreIdentifierKey: "com.powercan.obd-central"]
        )
    }

    func start() {
        guard centralManager.state == .poweredOn else { return }
        connectionStateSubject.send(.scanning)
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ])
    }

    func stop() {
        pollingTask?.cancel()
        pollingTask = nil
        centralManager.stopScan()
        if let p = peripheral {
            centralManager.cancelPeripheralConnection(p)
        }
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
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                self.sendCommand("010C\r")
                try? await Task.sleep(for: .milliseconds(150))
                self.sendCommand("010D\r")
                try? await Task.sleep(for: .milliseconds(150))

                if self.tickCount % 4 == 0 {
                    self.sendCommand("0105\r")
                    try? await Task.sleep(for: .milliseconds(150))
                    self.sendCommand("0106\r")
                    try? await Task.sleep(for: .milliseconds(150))
                    self.sendCommand("0107\r")
                    try? await Task.sleep(for: .milliseconds(150))
                }

                self.tickCount += 1
                try? await Task.sleep(for: .milliseconds(200))
            }
        }
    }

    private func sendCommand(_ command: String) {
        guard let characteristic = writeCharacteristic,
              let data = command.data(using: .ascii) else { return }
        peripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    private func parseResponse(_ raw: String) {
        let lines = raw.components(separatedBy: "\r")
        for line in lines {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: " ", with: "")

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
            case "06":
                if let a = hexByte(bytesHex, at: 0) {
                    data.shortTermFuelTrim = (Double(a) - 128) * (100.0 / 128.0)
                }
            case "07":
                if let a = hexByte(bytesHex, at: 0) {
                    data.longTermFuelTrim = (Double(a) - 128) * (100.0 / 128.0)
                }
            default:
                break
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
        guard reconnectAttempts < maxReconnectAttempts else {
            connectionStateSubject.send(.error)
            return
        }
        reconnectAttempts += 1
        let delay = pow(2.0, Double(reconnectAttempts))
        DispatchQueue.global().asyncAfter(deadline: .now() + min(delay, 30)) { [weak self] in
            self?.start()
        }
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            start()
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        peripheral.delegate = self
        central.stopScan()
        connectionStateSubject.send(.connecting)
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        reconnectAttempts = 0
        peripheral.discoverServices(serviceUUIDs)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        pollingTask?.cancel()
        attemptReconnect()
    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String: Any]) {
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral],
           let restored = peripherals.first {
            self.peripheral = restored
            restored.delegate = self
        }
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        for char in characteristics {
            if char.properties.contains(.notify) {
                peripheral.setNotifyValue(true, for: char)
            }
            if char.properties.contains(.write) || char.properties.contains(.writeWithoutResponse) {
                writeCharacteristic = char
            }
        }
        if writeCharacteristic != nil {
            Task { await runHandshake() }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value,
              let str = String(data: data, encoding: .ascii) else { return }

        responseBuffer += str
        if responseBuffer.contains(">") {
            parseResponse(responseBuffer)
            responseBuffer = ""
        }
    }
}
