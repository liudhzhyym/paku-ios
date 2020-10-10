//
//  AQICategory.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Foundation
import UIKit

enum AQICategory: Double, CaseIterable {
    case good                           = 0
    case moderate                       = 51
    case unhealthyForSensitiveGroups    = 101
    case unhealthy                      = 151
    case veryUnhealthy                  = 201
    case hazardous                      = 301

    init(aqi: Double) {
        switch aqi {
        case ...50: self = .good
        case ...100: self = .moderate
        case ...150: self = .unhealthyForSensitiveGroups
        case ...200: self = .unhealthy
        case ...300: self = .veryUnhealthy
        default: self = .hazardous
        }
    }

    var description: String {
        switch self {
        case .hazardous:
            return "Hazardous"
        case .veryUnhealthy:
            return "Very unhealthy"
        case .unhealthy:
            return "Unhealthy"
        case .unhealthyForSensitiveGroups:
            return "Unhealthy for sensitive groups"
        case .moderate:
            return "Moderate"
        case .good:
            return "Good"
        }
    }
}
