//
//  AQIConversion.swift
//  Paku
//
//  Created by Kyle Bashour on 10/20/20.
//

import Foundation

enum AQIConversion: Int, Codable, CaseIterable {
    case none = 0
    case AQAndU = 1
    case EPA = 2
}

extension AQIConversion {
    var name: String {
        switch self {
        case .none: return "None"
        case .AQAndU: return "AQAndU"
        case .EPA: return "EPA Wood Smoke"
        }
    }
}
