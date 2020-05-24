//
//  ViewControllerExtension.swift
//  Tracker
//
//  Created by Gronsky on 5/24/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreLocation

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLocation = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        distance = distance + (currentLocation.distance(from: prevLocation))
        prevLocation = currentLocation
    }
}
