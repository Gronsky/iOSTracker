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
    let Id: String
    let Name: String
    let Distance: Double
    let Duration: Int
    let Description: String?
    let Sport: String
    let Coordinates: [Coordinate]?
}
