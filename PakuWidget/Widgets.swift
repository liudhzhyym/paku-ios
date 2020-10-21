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
            AQIWidgetWrapper(entry: entry) { info in
                AQIEntryView(info: info)
            }
        }
        .configurationDisplayName("Color")
        .description("Displays the EPA color and guidance.")
    }
}

struct SkyWidget: Widget {
    let kind: String = "aqi_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AQIProvider()) { entry in
            AQIWidgetWrapper(entry: entry) { info in
                AQIBarWidgetView(info: info)
            }
        }
        .configurationDisplayName("Sky")
        .description("See the AQI on a scale, with a sky-like background.")
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
