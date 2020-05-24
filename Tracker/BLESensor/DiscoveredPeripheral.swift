//
//  DiscoveredPeripheral.swift
//  Tracker
//
//  Created by Gronsky on 5/12/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreBluetooth

class DiscoveredPeripheral {
    var peripheral: CBPeripheral
    var rssi: NSNumber
    var advertisementData: [String: Any]
    
    init(peripheral: CBPeripheral, rssi: NSNumber, advertisementData: [String: Any]) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertisementData = advertisementData
    }
    
}
