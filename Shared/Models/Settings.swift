//
//  Settings.swift
//  Paku
//
//  Created by Kyle Bashour on 10/29/20.
//

import Foundation
import UIKit

struct Settings: Equatable, Codable {

    var location: LocationType
    var conversion: AQIConversion

    init() {
        location = .outdoors
        conversion = .none
    }
}

enum LocationType: Int, Codable, CaseIterable {
    case outdoors = 0
    case indoors = 1
    case both = 2
}

extension LocationType {
    var symbolName: String {
        switch self {
        case .outdoors: return "sun.max.fill"
        case .indoors: return "building.2.fill"
        case .both: return "circle.grid.cross.fill"
        }
    }

    var name: String {
        switch self {
        case .outdoors: return "Outside"
        case .indoors: return "Inside"
        case .both: return "All"
        }
    }

    var tint: UIColor {
        switch self {
        case .outdoors: return .systemYellow
        case .indoors: return .systemGray
        case .both: return .systemGreen
        }
    }
}
