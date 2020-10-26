//
//  Bluetooth.swift
//  LockAndUnlock
//
//  Created by Khazan Gu on 2020/9/19.
//

// https://stackoverflow.com/a/22561588/14123004

import Foundation
import CoreBluetooth


// identifier for one peripheral Manager, declared outside the class:
let peripheralManagerIdentifier = "9BC1F0DC-F4CB-4159-BD38-720000000000"

// UUID for the advertisement service, declared outside the class:
let advertisementServiceUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7375CD0DD541")

// UUID for the one peripheral service, declared outside the class:
let writableServiceUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7375CD0DD542")

// UUID for one characteristic of the service above, declared outside the class:
let userNameCharacteristicUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7B74CD0CD543")

// UUID for one characteristic of the service above, declared outside the class:
let writableCharacteristicUUID = CBUUID(string: "9BC1F0DC-F4CB-4159-BD38-7B74CD0CD544")


protocol BluetoothDelegate {
    
    func updateRSSI(RSSI: String) -> Void
    
}


class Bluetooth: NSObject, CBPeripheralManagerDelegate {
    
    // While running the app in the background, the advertising doesn't contain the local name and all service UUIDs are put in the overflow area.

    public func startAdv() -> Void {
        
        if peripheralManager!.state == .poweredOn {
            
            if !peripheralManager!.isAdvertising {
                
                addService()
                
                let advertiseData = [CBAdvertisementDataLocalNameKey: "LockAndUnloack",
                                     CBAdvertisementDataServiceUUIDsKey: [advertisementServiceUUID]] as [String : Any]

                peripheralManager!.startAdvertising(advertiseData)
                                
            } else {
                
                print("isAdvertising")
                
            }
            
        } else {
            
            print("Please turn your Bluetooth on")
        }
        
    }
    
    public func stopAdv() -> Void {
        
        if peripheralManager!.state == .poweredOn {
            
            if !peripheralManager!.isAdvertising {

                peripheralManager!.stopAdvertising()
                                
            } else {
                
                print("not Advertising")
                
            }
            
        } else {
            
            print("Please turn your Bluetooth on")
            
        }
        
    }
    
    
    
    internal func writeUserName(userName:String, inCharacteristic: CBMutableCharacteristic, onSubscribedCentrals:[CBCentral]? , forPeripheral: CBPeripheralManager) -> Void {
        
        guard let data = userName.data(using: String.Encoding.utf8) else { return }
                    
        forPeripheral.updateValue(data, for: inCharacteristic, onSubscribedCentrals: onSubscribedCentrals)
        
    }
    
    internal func addService() -> Void {
        
        let service = CBMutableService(type: writableServiceUUID, primary: true)
            
        let data = NSUserName().data(using: String.Encoding.utf8)!
        
        let userNameCharacteristic = CBMutableCharacteristic(type: userNameCharacteristicUUID, properties: CBCharacteristicProperties.read, value: data, permissions: CBAttributePermissions.readable)
        
        let writableCharacteristic = CBMutableCharacteristic(type: writableCharacteristicUUID, properties: CBCharacteristicProperties.writeWithoutResponse, value: nil, permissions: CBAttributePermissions.writeable)
        
        let writableCharacteristicDescriptionUUID = CBUUID(string: CBUUIDCharacteristicUserDescriptionString)

        let writableCharacteristicDescriptor = CBMutableDescriptor(type: writableCharacteristicDescriptionUUID, value: "writableCharacteristiccDescriptor")
        
        writableCharacteristic.descriptors = [writableCharacteristicDescriptor]
                
        service.characteristics = [userNameCharacteristic, writableCharacteristic]
        
        peripheralManager!.add(service)
        
    }
    

    // MARK: CBPeripheralManagerDelegate
    internal func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        print("peripheralManagerDidUpdateState: \(peripheral.state.rawValue)")
        
    }
    
    internal func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        
        print("peripheralManager willRestoreState")
        
    }
    
    internal func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        print("peripheralManagerDidStartAdvertising: \(peripheral) error: \(String(describing: error))")
        
    }
    
    internal func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        print("peripheralManager didAdd service:\(service) error:\(String(describing: error))")
        
    }
    
    
    internal func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
         
        print("didSubscribeTo")
        
    }
    
    internal func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        
        print("didUnsubscribeFrom")
        
    }
    
    internal func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
//        print("peripheralManager didReceiveWrite \(requests)")
        
        guard let request = requests.first else { return }
        
        peripheral.respond(to: request, withResult: CBATTError.Code.success)
        
        guard let data = request.value else { return }
        
        guard let RSSI = String(data: data, encoding: String.Encoding.utf8) else { return }

        if let dl = delegate {
            
            dl.updateRSSI(RSSI: RSSI)
            
//            print("RSSI: \(RSSI) time: \(Date())")
            
        }
                        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        print("didReceiveRead")
        
    }
    
    
    
    internal var peripheralManager: CBPeripheralManager? = nil

    public var delegate: BluetoothDelegate?
    
    public var userName: String?
    
    
    override init() {
        
        super.init()
        
        let options = [CBPeripheralManagerOptionShowPowerAlertKey: true, CBPeripheralManagerOptionRestoreIdentifierKey: peripheralManagerIdentifier] as [String : Any]
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: DispatchQueue.main, options: options)
        
    }
    
}
