//
//  InterfaceController.swift
//  Watch Tracker Extension
//
//  Created by Gronsky on 5/22/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

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
        super.willActivate()
        
    }

    override func didDeactivate() {
        super.didDeactivate()
        
    }

}
