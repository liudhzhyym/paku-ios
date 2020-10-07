//
//  Widgets.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/1/20.
//

import WidgetKit
import SwiftUI

struct ColorWidget: Widget {
    let kind: String = "color"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AQIProvider()) { entry in
            AQIWidgetWrapper(entry: entry) { aqi in
                AQIEntryView(aqi: aqi)
            }
        }
        .configurationDisplayName("Color")
        .description("Displays the AQI from the closest Purple Air sensor.")
    }
}

struct SkyWidget: Widget {
    let kind: String = "aqi_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AQIProvider()) { entry in
            AQIWidgetWrapper(entry: entry) { aqi in
                AQIBarWidgetView(aqi: aqi)
            }
        }
        .configurationDisplayName("Sky")
        .description("Displays the AQI from the closest Purple Air sensor.")
        .supportedFamilies([.systemSmall])
    }
}

@main
struct AQIWidgets: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        SkyWidget()
        ColorWidget()
    }
}
