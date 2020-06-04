//
//  Coordinate.swift
//  Tracker
//
//  Created by Anastasia on 6/1/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreLocation

struct Coordinate: Codable {
    let Latitude: Double
    let Longitude: Double

    func locationCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.Latitude,
                                      longitude: self.Longitude)
    }
}
