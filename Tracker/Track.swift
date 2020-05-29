//
//  Track.swift
//  Tracker
//
//  Created by Anastasia on 5/25/20.
//  Copyright © 2020 Gronsky. All rights reserved.
//

import Foundation

struct Track: Codable {
    let id: String
    let name: String
    let description: String?
    let sport: String
    let distance: Double
    let time: Int
}
