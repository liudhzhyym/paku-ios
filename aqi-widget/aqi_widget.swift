//
//  aqi_widget.swift
//  aqi-widget
//
//  Created by Kyle Bashour on 10/1/20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: TimelineProvider {
    let loader = AQILoader()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), aqi: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), aqi: .placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        loader.closestAQIOrCached { result in
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 11, to: currentDate)!
            let entry = SimpleEntry(date: currentDate, aqi: try? result.get())
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let aqi: AQI?
}

struct WidgetView: View {
    var entry: SimpleEntry

    var body: some View {
        if let aqi = entry.aqi {
            AQIEntryView(aqi: aqi)
        } else {
            HStack {
                Text("We couldn't load anything 😕 try opening the app")
                    .font(.caption)
                    .padding()
                Spacer()
            }
        }
    }
}

@main
struct aqi_widget: Widget {
    let kind: String = "aqi_widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
        }
        .configurationDisplayName("AQI")
        .description("Displays the AQI from the closest Purple Air sensor.")
    }
}

struct AQIWidget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetView(entry: SimpleEntry(date: Date(), aqi: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        WidgetView(entry: SimpleEntry(date: Date(), aqi: nil))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension AQI {
    static let placeholder = AQI(value: 20, distance: 100, date: Date())
}
