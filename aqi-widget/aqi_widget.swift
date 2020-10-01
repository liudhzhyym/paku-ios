//
//  aqi_widget.swift
//  aqi-widget
//
//  Created by Kyle Bashour on 10/1/20.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    let loader = AQILoader()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), aqi: .placeholder)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, aqi: .placeholder)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        loader.loadClosestAQI { result in
            switch result {
            case .success(let aqi):
                let currentDate = Date()
                let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
                let entry = SimpleEntry(date: currentDate, configuration: configuration, aqi: aqi)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)

            case .failure(let error):
                print("Error: \(error)")

            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let aqi: AQI
}

@main
struct aqi_widget: Widget {
    let kind: String = "aqi_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            AQIEntryView(aqi: entry.aqi)
        }
        .configurationDisplayName("AQI")
        .description("Displays the AQI from the closest Purple Air sensor.")
    }
}

struct AQIWidget_Previews: PreviewProvider {
    static var previews: some View {
        AQIEntryView(aqi: .placeholder)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension AQI {
    static let placeholder = AQI(value: 20, distance: 100, date: Date())
}
