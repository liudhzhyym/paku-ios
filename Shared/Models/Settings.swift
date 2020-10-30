//
//  Settings.swift
//  Paku
//
//  Created by Kyle Bashour on 10/29/20.
//

import Foundation

struct Settings: Codable {

    var location: Location
    var conversion: AQIConversion

    init() {
        location = .outdoors
        conversion = .EPA
    }
}

enum Location: Int, Codable {
    case outdoors
    case indoors
    case both
}
