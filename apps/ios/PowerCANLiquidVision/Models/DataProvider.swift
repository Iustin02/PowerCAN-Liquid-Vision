import Foundation
import Combine

protocol DataProvider: AnyObject {
    var obdDataPublisher: AnyPublisher<OBDData, Never> { get }
    var connectionStatePublisher: AnyPublisher<ConnectionState, Never> { get }
    var currentData: OBDData { get }
    var connectionState: ConnectionState { get }

    func start()
    func stop()
}
