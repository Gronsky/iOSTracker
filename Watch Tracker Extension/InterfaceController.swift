//
//  InterfaceController.swift
//  Watch Tracker Extension
//
//  Created by Настенька on 5/23/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var timeLabel: WKInterfaceLabel!
    
    @IBOutlet weak var avgSpeedLabel: WKInterfaceLabel!
    
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    
    @IBOutlet weak var startButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
