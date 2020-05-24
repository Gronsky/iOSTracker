//
//  PeripheralsViewController.swift
//  Tracker
//
//  Created by Gronsky on 5/12/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import UIKit

class PeripheralsViewController: UITableViewController {
    
    var central: BLECentral!
    var onConnected: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        central.onDiscovered = { [weak self] in
            self?.tableView.reloadData()
        }
        
        central?.onConnected = { [weak self] in
            self?.onConnected?()
        }
        
        tableView.register(UINib(nibName: "DiscoveredPeripheralCell", bundle: nil), forCellReuseIdentifier: "DiscoveredPeripheralCell")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return central.discoveredPeripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiscoveredPeripheralCell", for: indexPath) as! DiscoveredPeripheralCell
        let discoveredPeripheral =  central.discoveredPeripherals[indexPath.row]
        
        
        if discoveredPeripheral.peripheral.name != nil {
            cell.identifierLabel.text = String("\(discoveredPeripheral.peripheral.name)  \(discoveredPeripheral.peripheral.identifier.uuidString)")
        } else {
            cell.identifierLabel.text = discoveredPeripheral.peripheral.identifier.uuidString
        }
        
        cell.rssiLabel.text = discoveredPeripheral.rssi.stringValue
        cell.advertisementLabel.text =  discoveredPeripheral.advertisementData.debugDescription
        
        cell.identifierLabel.textColor = .blue
        cell.rssiLabel.textColor = .red
        
        return cell
    }

    // Table view delegate for connection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        central.connect(at: indexPath.row)
        self.dismiss(animated:true)
    }
}
