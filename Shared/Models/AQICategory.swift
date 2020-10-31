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

    struct Guidance {
        let title: String
        let body: String
    }

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

    var guidance: [Guidance] {
        switch self {
        case .hazardous:
            return [
                Guidance(title: "Everyone", body: "Avoid all physical outdoor activities."),
                Guidance(title: "Sensitive groups", body: "Remain indoors and keep activity levels low. Follow tips for keeping particle levels low indoors."),
            ]
        case .veryUnhealthy:
            return [
                Guidance(title: "Sensitive groups", body: "Avoid all physical activity outdoors. Move activities indoors or reschedule to a time when air quality is better."),
                Guidance(title: "Everyone else", body: "Avoid prolonged or heavy exertion. Consider moving activities indoors or rescheduling to a time when air quality is better."),
            ]
        case .unhealthy:
            return [
                Guidance(title: "Sensitive Groups", body: "Avoid prolonged or heavy exertion. Move activities indoors or reschedule to a time when air quality is better."),
                Guidance(title: "Everyone else", body: "Reduce prolonged or heavy exertion. Take more breaks during all outdoor activities."),
            ]
        case .unhealthyForSensitiveGroups:
            return [
                Guidance(title: "Sensitive Groups", body: "Reduce prolonged or heavy exertion. It’s okay to be active outside, but take more breaks and do less intense activities. Watch for symptoms such as coughing or shortness of breath."),
                Guidance(title: "Everyone else", body: "It’s okay to be active outside, but consider reducing prolonged or heavy exertion."),
            ]
        case .moderate:
            return [
                Guidance(title: "Unusually sensitive people", body: "Consider reducing prolonged or heavy exertion. Watch for symptoms such as coughing or shortness of breath. These are signs to take it easier."),
                Guidance(title: "Everyone else", body: "It’s a good day to be active outside."),
            ]
        case .good:
            return [
                Guidance(title: "Guidance", body: "It’s a great day to be active outside!")
            ]
        }
    }
}
