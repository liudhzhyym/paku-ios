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

extension AQIClass {
    var color: UIColor {
        switch self {
        case .veryHazardous:
            return UIColor(displayP3Red: 0.451, green: 0.078, blue: 0.145, alpha: 1)
        case .hazardous:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .veryUnhealthy:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .unhealthy:
            return UIColor(displayP3Red: 0.918, green: 0.2, blue: 0.141, alpha: 1)
        case .unhealthyForSensitiveGroups:
            return UIColor(displayP3Red: 0.937, green: 0.522, blue: 0.2, alpha: 1)
        case .moderate:
            return UIColor(displayP3Red: 1, green: 1, blue: 0.333, alpha: 1)
        case .good:
            return UIColor(displayP3Red: 0.408, green: 0.882, blue: 0.263, alpha: 1)
        }
    }

    var textColor: UIColor {
        switch self {
        case .veryHazardous, .hazardous, .veryUnhealthy, .unhealthy:
            return .white
        default:
            return .black
        }
    }

    static func color(at aqi: Double) -> UIColor {
        return AQIClass(aqi: aqi).color
    }
}

