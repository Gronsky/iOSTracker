//
//  Track.swift
//  Tracker
//
//  Created by Anastasia on 5/25/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation
import CoreLocation

struct Track: Codable {
    var Id: String
    var Name: String
    var Date: String
    var Duration: Int64
    var Distance: Double
    var Description: String?
    var Sport: String
    //var Coordinates: [Coordinate]?
}

