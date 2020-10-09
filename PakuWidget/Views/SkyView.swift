//
//  SkyView.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit

struct SkyView: View {

    var category: AQICategory

    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [category.topColor, category.bottomColor]
            ),
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

private extension AQICategory {
    var topColor: Color {
        switch self {
        case .good, .moderate:
            return Color(red: 0.282, green: 0.525, blue: 0.725)
        case .unhealthy, .unhealthyForSensitiveGroups:
            return Color(red: 0.255, green: 0.396, blue: 0.495)
        case .veryUnhealthy, .hazardous:
            return Color(red: 0.479, green: 0.420, blue: 0.210)
        }
    }

    var bottomColor: Color {
        return Color(red: 0.459, green: 0.655, blue: 0.780)
    }
}

struct SkyView_Previews: PreviewProvider {
    static var previews: some View {
        SkyView(category: .good)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .unhealthy)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        SkyView(category: .hazardous)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

    }
}
