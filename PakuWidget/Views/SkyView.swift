//
//  SkyView.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import CoreLocation
import SwiftUI
import WidgetKit

struct SkyView: View {

    var category: AQICategory

    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    category.topColor(),
                    category.bottomColor()
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private extension AQICategory {
    private var dayTopColor: UIColor {
        switch self {
        case .good:
            return UIColor(displayP3Red: 66 / 255.0, green: 136 / 255.0, blue: 181 / 255.0, alpha: 1)
        case .moderate:
            return UIColor(displayP3Red: 0.282, green: 0.525, blue: 0.725, alpha: 1)
        case .unhealthy, .unhealthyForSensitiveGroups:
            return UIColor(hex: "7b8d9d")
        case .veryUnhealthy, .hazardous:
            return UIColor(displayP3Red: 0.379, green: 0.320, blue: 0.250, alpha: 1)
        }
    }

    private var dayBottomColor: UIColor {
        switch self {
        case .good:
            return UIColor(displayP3Red: 119 / 255.0, green: 169 / 255.0, blue: 201 / 255.0, alpha: 1)
        case .moderate:
            return UIColor(hex: "7c8e9d")
        case .unhealthy, .unhealthyForSensitiveGroups:
            return UIColor(hex: "4b5c6d")
        default:
            return UIColor(hex: "4b5c6d")
        }
    }

    private var nightTopColor: UIColor {
        switch self {
        case .good, .moderate:
            return UIColor(displayP3Red: 1 / 255.0, green: 5 / 255.0, blue: 32 / 255.0, alpha: 1)
        default:
            return UIColor(displayP3Red: 54 / 255.0, green: 57 / 255.0, blue: 60 / 255.0, alpha: 1)
        }
    }

    private var nightBottomColor: UIColor {
        switch self {
        case .good, .moderate:
            return UIColor(displayP3Red: 50 / 255.0, green: 58 / 255.0, blue: 87 / 255.0, alpha: 1)
        default:
            return UIColor(displayP3Red: 26 / 255.0, green: 28 / 255.0, blue: 31 / 255.0, alpha: 1)
        }
    }

    func topColor() -> Color {
        Color(UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: return nightTopColor
            default: return dayTopColor
            }
        })
    }

    func bottomColor() -> Color {
        Color(UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark: return nightBottomColor
            default: return dayBottomColor
            }
        })
    }
}

struct SkyView_Previews: PreviewProvider {
    static var previews: some View {
        SkyView(category: .good)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .moderate)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .unhealthy)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .hazardous)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .good)
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .hazardous)
            .environment(\.colorScheme, .dark)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

    }
}
