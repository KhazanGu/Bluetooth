//
//  BluetoothControler.swift
//  LockAndUnlock
//
//  Created by Khazan Gu on 2020/9/19.
//

import Foundation
import UIKit
import CoreBluetooth

// identifier for one centralManager, declared outside the class:
let centralManagerIdentifier = "9BC1F0DC-F4CB-4159-BD38-7375CD0DD540"

// UUID for the advertisement service, declared outside the class:
let advertisementServiceUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7375CD0DD541")

// UUID for the one peripheral service, declared outside the class:
let writableServiceUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7375CD0DD542")

// UUID for one characteristic of the service above, declared outside the class:
let userNameCharacteristicUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7B74CD0CD543")

// UUID for one characteristic of the service above, declared outside the class:
let writableCharacteristicUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7B74CD0CD544")


class BluetoothControler: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    public func launchWithOptions(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Void {
        
        if let lop = launchOptions {

            if let centrals = lop[.bluetoothCentrals] as? Array<String> {
                
                let filters = centrals.filter { (uid: String) -> Bool in
                              
                    return centralManagerIdentifier.elementsEqual(uid)
                    
                }
                
                if let store = filters.first {
                    
                    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: store])

                } else {
                    
                    centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: centralManagerIdentifier])

                }
                
            } else {
                
                centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: centralManagerIdentifier])

            }
            
        } else {

            centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey: centralManagerIdentifier])

        }
        
    }
    
    
    public func startScan() -> Void {
        
        if centralManager.state == .poweredOn {
            
            scan(withServices: [advertisementServiceUUID])
            
        } else {
            
            print("Please turn your Bluetooth on");
            
        }
        
    }
    
    // MARK: scan
    private func scan(withServices: [CBUUID]) -> Void {
        
        print("action ******* scan: \(withServices)" )
        
        centralManager.scanForPeripherals(withServices: withServices, options: [CBCentralManagerScanOptionSolicitedServiceUUIDsKey: withServices, CBCentralManagerScanOptionAllowDuplicatesKey: false])

    }
    
    // MARK: stop scan
    private func stopSacn() -> Void {
        
        print("action ******* stopSacn" )

        centralManager.stopScan()
        
    }
    
    /* MARK: connect
     
     CBConnectPeripheralOptionNotifyOnConnectionKey-如果您希望系统在建立成功的连接后被挂起，则系统希望显示给定外围设备的警报，请包括此键。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey-如果您希望系统在给定外围设备显示断开连接的状态时显示断开连接警报，则包括此密钥。
     CBConnectPeripheralOptionNotifyOnNotificationKey-如果您希望系统在该应用程序当时被暂停的情况下显示从给定外围设备收到的所有通知的警报，请包含此密钥。
     */
    private func connect(peripheral: CBPeripheral) -> Void {
        
        // ??? options
        if peripheral.state == .disconnected {
            
            print("action ******* connect" )

            let options = [CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                           CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                           CBConnectPeripheralOptionNotifyOnNotificationKey: true]
            
            centralManager.connect(peripheral, options: options)

        } else {
            
            print("peripheral is connected")
            
        }
        
    }
    
    // MARK: reconnect Peripherals
    private func reconnectPeripherals() -> Void {
        
        if self.peripherals.count == 0 {
            return;
        }
        
        print("action ******* reconnect" )
        
        for peripheral in self.peripherals {
            
            connect(peripheral: peripheral);
            
        }
        
    }
    
    // MARK: discover Services
    func discoverServices(peripheral: CBPeripheral) -> Void {
        
        peripheral.discoverServices([writableServiceUUID])
                
    }
    
    // MARK: discover Characteristics
    func discoverCharacteristics(peripheral: CBPeripheral, service: CBService) -> Void {
        
        peripheral.discoverCharacteristics([userNameCharacteristicUUID ,writableCharacteristicUUID], for: service)
        
    }
    
    // MARK: notify Characteristic
    func notifyCharacteristic(peripheral: CBPeripheral, characteristic: CBCharacteristic) -> Void {
        
        if characteristic.uuid == writableCharacteristicUUID {
            
            peripheral.setNotifyValue(true, for: characteristic)

        }

    }
    
    func sendRSSI(RSSI: NSNumber, toPerpheral: CBPeripheral) -> Void {
        
        guard let writeServer = filterServer(server: writableServiceUUID, inPeripheral: toPerpheral) else { return }
        
        guard let writeCharacteristic = filterCharacteristic(characteristic: writableCharacteristicUUID, inServer: writeServer) else { return }
        
        let data = Data(RSSI.stringValue.utf8)
        
        wirteValue(data: data, forCharacteristic: writeCharacteristic, toPerpheral: toPerpheral)
        
    }
    
    
    func wirteValue(data: Data, forCharacteristic: CBCharacteristic, toPerpheral: CBPeripheral) -> Void {
        
        toPerpheral.writeValue(data, for: forCharacteristic, type: CBCharacteristicWriteType.withoutResponse)

    }
    
    
    func readData(forCharacteristic: CBCharacteristic, inPerpheral: CBPeripheral) -> Void {
        
        inPerpheral.readValue(for: forCharacteristic)
        
    }
    
    // restore State
    func restoreStateWithRestoredData(dict: [String : Any]) -> Void {

        // Store CBCentralManagerRestoredStatePeripheralsKey when killed the app is connected.
        if let peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey] as? Array<CBPeripheral> {

            restoreStateWithPeripherals(peripherals: peripherals)

        }

        // Store CBCentralManagerRestoredStateScanServicesKey when killed the app is scaning.
        if let services = dict[CBCentralManagerRestoredStateScanServicesKey] as? Array<CBUUID> {

            scan(withServices: services)

        }

    }
    
    // restore State With connected Peripherals
    func restoreStateWithPeripherals(peripherals: Array<CBPeripheral>) -> Void {

        print("restoreStateWithPeripherals")

        self.objectWillChange.send()

        self.peripherals.append(contentsOf: peripherals)

        let lperipherals = peripherals.map { (peripheral: CBPeripheral) -> LPeripheral in

            peripheral.delegate = self;
            
            let lp = LPeripheral(fromName: peripheral.name, userName: nil, rssi: 0, uuid: peripheral.identifier)

            return lp

        }

        infos.append(contentsOf: lperipherals)

    }
    
    
    /* MARK: CBCentralManagerDelegate
      
     close Bluetooth via control center. disconnect automatically, didDisconnectPeripheral method did't call.
     
     close Bluetooth via Setting-Bluetooth. disconnect automatically, didDisconnectPeripheral method did't call.
     
     So, should connect peripherals automatically when centralManagerDidUpdateState update to 5.
     
     And the peripheral must be advertising when the centralManager to connect the peripheral. peripheral shouldn't stop advertising at any time.

     */
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("centralManagerDidUpdateState: \(central.state.rawValue)")
        
        state = central.state
        
        if central.state == .poweredOn {

            reconnectPeripherals();

        }
        
    }
    
    internal func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
        print("willRestoreState: \(dict)")

        restoreStateWithRestoredData(dict: dict)

    }

    internal func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("action ******* did Discover peripheral: \(peripheral)")
        
        if !peripherals.contains(peripheral) {
            
            peripherals.append(peripheral)

            infos.append(LPeripheral(fromName: peripheral.name, userName: nil, rssi: RSSI, uuid: peripheral.identifier))

            connect(peripheral: peripheral)

        }
        
    }
    
    // The first connected device doesn't have services
    internal func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        print("action ******* did Connect peripheral: \(peripheral)")
                
        stopSacn()
        
        peripheral.delegate = self;

        discoverServices(peripheral: peripheral)

    }
    
    internal func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: \(peripheral)")
        
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral: \(peripheral)")
                
        let options = [CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                       CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                       CBConnectPeripheralOptionNotifyOnNotificationKey: true]
        
        central.connect(peripheral, options: options)
        
    }
    
    
    private func readAllPeripheralsRSSI() -> Void {
        
        if state != .poweredOn {
            
            return;
            
        }
        
        peripherals.forEach { (peripheral) in

            readRSSI(peripheral: peripheral)

        }
        
    }
    
    private func readRSSI(peripheral: CBPeripheral) -> Void {

        if peripheral.state == .connected {

            peripheral.readRSSI()

        }

    }
    
    // filter Server
    func filterServer(server: CBUUID, inPeripheral: CBPeripheral) -> CBService? {
        
        guard let servers = inPeripheral.services else { return nil }
                
        let results = servers.filter { (ser) -> Bool in
                        
            return ser.uuid == server
            
        }
        
        guard let fitler = results.first else { return nil }
        
        return fitler
        
    }

    // filter Characteristic
    func filterCharacteristic(characteristic: CBUUID, inServer: CBService) -> CBCharacteristic? {
        
        guard let characteristics = inServer.characteristics else { return nil }
                
        let results = characteristics.filter { (cha) -> Bool in
                        
            return cha.uuid == characteristic
            
        }
        
        guard let fitler = results.first else { return nil }
        
        return fitler
        
    }
    
    
    // MARK: CBPeripheralDelegate
    
    /*
     CBAdvertisementDataTxPowerLevelKey
     https://stackoverflow.com/a/45431617/14123004
     */
    internal func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
//        print("peripheral didReadRSSI: \(RSSI)")
                
        sendRSSI(RSSI: RSSI, toPerpheral: peripheral);

        self.objectWillChange.send()

        infos.forEach { (lp) in
            
            if lp.uuid == peripheral.identifier {
             
                lp.rssi = RSSI
                                
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("action ******* did Discover Services")
        
        guard let services = peripheral.services else { return }

        for service in services {

            discoverCharacteristics(peripheral: peripheral, service: service)

        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("action ******* did Discover CharacteristicsFor")
        
        guard let characteristics = service.characteristics else { return }
        
        let userNameCharacteristics = characteristics.filter { (characteristic) -> Bool in
                        
            return characteristic.uuid == userNameCharacteristicUUID
            
        }
        
        guard let userNameCharacteristic = userNameCharacteristics.first else { return }
        
        readData(forCharacteristic: userNameCharacteristic, inPerpheral: service.peripheral)

    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("action ******* did Discover DescriptorsFor")

    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        print("didUpdateValueFor \(characteristic)")
        
        if characteristic.uuid == userNameCharacteristicUUID {
            
            guard let data = characteristic.value else { return }
            
            guard let userName = String(data: data, encoding: String.Encoding.utf8) else { return }

            infos.forEach { (lp) in
                
                if lp.uuid == characteristic.service.peripheral.identifier {
                    
                    lp.userName = userName
                    
                }
                
            }
            
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        
        print("didModifyServices")
        
        discoverServices(peripheral: peripheral)
        
    }
    
    
        
    
    static let sharedInstance = BluetoothControler()
    
    private var centralManager: CBCentralManager!
    
    var state = CBManagerState.unknown
    
    var timer: DispatchSourceTimer!
    
    private var peripherals = [CBPeripheral]()
    
    @Published public var infos = [LPeripheral]()
    
    
    
    private override init() {
        super.init()
                        
        timer = DispatchSource.makeTimerSource()

        timer.schedule(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(1), repeating: DispatchTimeInterval.seconds(1), leeway: DispatchTimeInterval.never)

        timer.setEventHandler {
            
            self.readAllPeripheralsRSSI()

        };

        timer.resume()
        
    }
    
    
}


class LPeripheral: NSObject {

    internal var _deviceName: String?
    
    internal var _userName: String?

    internal var _rssi: NSNumber!
    
    internal var _uuid: UUID!
        
    
    var deviceName: String {
        
        get {
            
            if let ifName = _deviceName {
                return ifName
            }
            
            return ""
            
        }
        
        set {
            
            _deviceName = newValue
            
        }
        

    }
    
    var userName: String {
        
        get {
            
            if let ifName = _userName {
                return ifName
            }
            
            return ""
            
        }
        
        set {
            
            _userName = newValue
            
        }
        

    }
    
    var rssi: NSNumber {
        
        set {
            
            _rssi = newValue
            
        }
        
        get {
            
            return _rssi

        }
    }
    
    var uuid: UUID {
        
        set {
           
            _uuid = newValue
            
        }
        
        get {
            
            return _uuid

        }
        
    }
    
    init(fromName deviceName: String?, userName: String?, rssi: NSNumber, uuid: UUID) {
        
        _deviceName = deviceName
        
        _userName = userName
        
        _rssi = rssi
        
        _uuid = uuid
        
    }
    
}
