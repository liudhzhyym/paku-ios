//
//  AQICategory+Color.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import UIKit

extension AQICategory {

    var epaColor: UIColor {
        switch self {
        case .hazardous:
            return UIColor(hex: "89117A")
        case .veryUnhealthy:
            return UIColor(hex: "9D05C3")
        case .unhealthy:
            return UIColor(hex: "AD00FA")
        case .unhealthyForSensitiveGroups:
            return UIColor(hex: "FF4444")
        case .moderate:
            return UIColor(hex: "FFC50B")
        case .good:
            return UIColor(hex: "35C759")
        }
    }

    static func epaColor(for aqi: Double) -> UIColor {
        let category = AQICategory(aqi: aqi)

        var lower: AQICategory
        var upper: AQICategory

        if category == .good {
            lower = .good
            upper = .moderate
        } else if category == .hazardous {
            lower = .veryUnhealthy
            upper = .hazardous
        } else {
            upper = category
            let index = AQICategory.allCases.firstIndex(of: category)!
            lower = AQICategory.allCases[index - 1]
        }

        let range = upper.rawValue - lower.rawValue
        let valueInRange = aqi - lower.rawValue
        let fraction = valueInRange / range

        return lower.epaColor.interpolateHSVColorTo(upper.epaColor, fraction: CGFloat(fraction))
    }
}
