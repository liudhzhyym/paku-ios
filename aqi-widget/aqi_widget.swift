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
                let refreshDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
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

struct aqi_widgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Color(entry.aqi.class.color)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(entry.aqi.value))")
                        .font(.title)
                        .foregroundColor(Color(entry.aqi.class.textColor))

                    Text(entry.date, style: .time)
                        .font(Font.caption)
                        .foregroundColor(Color(entry.aqi.class.textColor))


                    Spacer()

                    Text(entry.aqi.class.description)
                        .font(.body)
                        .foregroundColor(Color(entry.aqi.class.textColor))
                }

                Spacer()
            }.padding()
        }
    }
}

@main
struct aqi_widget: Widget {
    let kind: String = "aqi_widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            aqi_widgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct aqi_widget_Previews: PreviewProvider {
    static var previews: some View {
        aqi_widgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), aqi: .placeholder))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension AQI {
    static let placeholder = AQI(value: 20, distance: 100, date: Date())
}
