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

    override func viewDidLoad() {
        super.viewDidLoad()

        central.onDiscovered = {
            [weak self] in self?.tableView.reloadData()
        }
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
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let peripheral = central.discoveredPeripherals[indexPath.row]
        cell.textLabel?.text = peripheral.name
        cell.detailTextLabel?.text = peripheral.identifier.uuidString
        
        return cell
    }

}
