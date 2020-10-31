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

    var detailedDescription: String {
        switch self {
        case .hazardous:
            return "Health warnings of emergency conditions. The entire population is more likely to be affected."
        case .veryUnhealthy:
            return "Health alert: everyone may experience more serious health effects."
        case .unhealthy:
            return "Everyone may begin to experience health effects; members of sensitive groups may experience more serious health effects."
        case .unhealthyForSensitiveGroups:
            return "Members of sensitive groups may experience health effects. The general public is not likely to be affected."
        case .moderate:
            return "Air quality is acceptable; however, for some pollutants there may be a moderate health concern for a very small number of people who are unusually sensitive to air pollution."
        case .good:
            return "Air quality is considered satisfactory, and air pollution poses little or no risk."
        }
    }
}
