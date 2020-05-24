//
//  BLECentral.swift
//  Tracker
//
//  Created by Gronsky on 5/11/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLECentral: NSObject, CBCentralManagerDelegate {
    
    var manager: CBCentralManager!
    var discoveredPeripherals = [CBPeripheral]()
    var onDiscovered: (()->Void)?
    
    override init(){
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func scanForPeripherals(){
        manager.scanForPeripherals(withServices: nil, options: nil)
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
        discoveredPeripherals.append(peripheral)
        onDiscovered?()
    }


}
