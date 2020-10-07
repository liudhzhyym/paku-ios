//
//  AQISnapshot.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Foundation
import CoreLocation

struct AQI: Codable {
    let value: Double
    let distance: CLLocationDistance
    let date: Date

    var `class`: AQIClass {
        AQIClass(aqi: value)
    }
}
