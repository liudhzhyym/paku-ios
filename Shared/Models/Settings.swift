//
//  Settings.swift
//  Paku
//
//  Created by Kyle Bashour on 10/29/20.
//

import Foundation

struct Settings: Equatable, Codable {

    var location: LocationType
    var conversion: AQIConversion

    init() {
        location = .outdoors
        conversion = .EPA
    }
}

enum LocationType: Int, Codable, CaseIterable {
    case outdoors = 0
    case indoors = 1
    case both = 2
}
