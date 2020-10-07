//
//  AQIClass.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Foundation
import UIKit

enum AQIClass: Double, CaseIterable {
    case good                           = 50
    case moderate                       = 100
    case unhealthyForSensitiveGroups    = 150
    case unhealthy                      = 200
    case veryUnhealthy                  = 300
    case hazardous                      = 400
    case veryHazardous                  = 500

    init(aqi: Double) {
        switch aqi {
        case ...50: self = .good
        case ...100: self = .moderate
        case ...150: self = .unhealthyForSensitiveGroups
        case ...200: self = .unhealthy
        case ...300: self = .veryUnhealthy
        case ...400: self = .hazardous
        default: self = .veryHazardous
        }
    }

    var description: String {
        switch self {
        case .veryHazardous:
            return "Very hazardous"
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
