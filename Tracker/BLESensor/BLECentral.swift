//
//  BLECentral.swift
//  Tracker
//
//  Created by Anastasia on 5/11/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentral: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private var centralManager: CBCentralManager!

    // MARK: - Core Bluetooth service IDs
//    let heartRateServiceCBUUID = CBUUID(string: "0x180D")
//
//    // MARK: - Core Bluetooth characteristic IDs
//    let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "0x2A37")
//    let bodySensorLocationCharacteristicCBUUID = CBUUID(string: "0x2A38")
     
    private(set) var discoveredPeripherals = [DiscoveredPeripheral]()
    private var connectedPeripheral: CBPeripheral?
    private let decoder = JSONDecoder()
    
    var onDiscovered: (()->Void)?
    var onDataUpdated: ((Int)->Void)?
    var onConnected: (()->Void)?
    
    override init(){
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals(){
        let options: [String: Any] = [CBCentralManagerScanOptionAllowDuplicatesKey: false]
        centralManager.scanForPeripherals(withServices: nil, options: options)
    }
    
    func connect(at index: Int) {
        guard index >= 0, index < discoveredPeripherals.count else { return }
        
        centralManager.stopScan()
        centralManager.connect(discoveredPeripherals[index].peripheral, options: nil)
    }
    
    func  centralManagerDidUpdateState(_ central : CBCentralManager) {
        if central.state == .poweredOn{
            print("central is powered on")
            scanForPeripherals()
        }
        else{
            print("central is unavailable: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let existingPeripheral = discoveredPeripherals.first(where: {$0.peripheral == peripheral}) {
            existingPeripheral.advertisementData = advertisementData
            existingPeripheral.rssi = RSSI
        }
        else {
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, rssi: RSSI, advertisementData: advertisementData))
        }
        
        onDiscovered?()
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("central did connect")
        connectedPeripheral = peripheral
        connectedPeripheral?.delegate = self
        connectedPeripheral?.discoverServices(nil)  // [heartRateServiceCBUUID]
        onConnected?()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("central did fail to connect")
    }
    
    // MARK: - CBPeripheralDelegate
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("peripheral failed to discover services: \(error.localizedDescription)")
        }
        else {
            peripheral.services?.forEach({ (service) in
                print("service discovered: \(service)")
                peripheral.discoverCharacteristics(nil, for: service)  //  [heartRateServiceCBUUID]
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("peripheral failed to discover characteristics: \(error.localizedDescription)")
        } else {
            service.characteristics?.forEach({ (characteristic) in
                print("characteristic discovered: \(characteristic)")
                
                // subscribe
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    
                } else if characteristic.properties.contains(.read) {
                    peripheral.readValue(for: characteristic)
                }
                
                peripheral.discoverDescriptors(for: characteristic)
            })
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("peripheral failed to discover descriptor: \(error.localizedDescription)")
        } else {
            characteristic.descriptors?.forEach({ (descriptor) in
                print("descriptor discovered: \(descriptor)")
                
                peripheral.readValue(for: descriptor)
            })
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("peripheral error updating for characteristic: \(error.localizedDescription)")
        } else {
            print("characteristic value updated: \(characteristic)")
            
            if let value = characteristic.value {
//                if let heartRateData = try? decoder.decode(HeartRateData.self, from: value) {
//                    print("__________ = \(heartRateData)")
                
                
                // MARK: Decode BLE
                // data into human readable format
                let heartRateData = deriveBeatsPerMinute(using: characteristic)
                print("__________ = \(heartRateData)")

                onDataUpdated?(heartRateData)
            }
         }
    }

    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if let error = error {
            print("peripheral error updating for descriptor: \(error.localizedDescription)")
        } else {
            print("descriptor value updated: \(descriptor)")
        }
    }


func deriveBeatsPerMinute(using heartRateMeasurementCharacteristic: CBCharacteristic) -> Int {
    
    let heartRateValue = heartRateMeasurementCharacteristic.value!
    // convert to an array of unsigned 8-bit integers
    let buffer = [UInt8](heartRateValue)

    // if least significant bit (LSB) is 0, heart rate (bpm) is UInt8
    // if LSB is 1, BPM is UInt16
    if (buffer.count > 1) {
        
        if ((buffer[0] & 0x01) == 0) {
            print("BPM is UInt8")
            return Int(buffer[1])
        } else {
            print("BPM is UInt16")
            return -1
        }
        
    } else {
        return -1
    }
    
}

}
