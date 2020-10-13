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
    @Environment(\.isDayTime) var isDaytime

    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    category.topColor(isDay: isDaytime),
                    category.bottomColor(isDay: isDaytime)
                ]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private extension AQICategory {
    private var dayTopColor: Color {
        switch self {
        case .good:
            return Color(red: 66 / 255.0, green: 136 / 255.0, blue: 181 / 255.0)
        case .moderate:
            return Color(red: 0.282, green: 0.525, blue: 0.725)
        case .unhealthy, .unhealthyForSensitiveGroups:
            return Color(UIColor(hex: "7b8d9d"))
        case .veryUnhealthy, .hazardous:
            return Color(red: 0.379, green: 0.320, blue: 0.250)
        }
    }

    private var dayBottomColor: Color {
        switch self {
        case .good:
            return Color(red: 119 / 255.0, green: 169 / 255.0, blue: 201 / 255.0)
        case .moderate:
            return Color(UIColor(hex: "7c8e9d"))
        case .unhealthy, .unhealthyForSensitiveGroups:
            return Color(UIColor(hex: "4b5c6d"))
        default:
            return Color(UIColor(hex: "4b5c6d"))
        }
    }

    private var nightTopColor: Color {
        switch self {
        case .good, .moderate:
            return Color(red: 1 / 255.0, green: 5 / 255.0, blue: 32 / 255.0)
        default:
            return Color(red: 54 / 255.0, green: 57 / 255.0, blue: 60 / 255.0)
        }
    }

    private var nightBottomColor: Color {
        switch self {
        case .good, .moderate:
            return Color(red: 50 / 255.0, green: 58 / 255.0, blue: 87 / 255.0)
        default:
            return Color(red: 26 / 255.0, green: 28 / 255.0, blue: 31 / 255.0)
        }
    }

    func topColor(isDay: Bool) -> Color {
        isDay ? dayTopColor : nightTopColor
    }

    func bottomColor(isDay: Bool) -> Color {
        isDay ? dayBottomColor : nightBottomColor
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
            .environment(\.isDayTime, false)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .hazardous)
            .environment(\.isDayTime, false)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

    }
}
