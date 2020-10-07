//
//  AQIProvider.swift
//  aqi-widgetExtension
//
//  Created by Kyle Bashour on 10/6/20.
//

import WidgetKit

struct SimpleEntry: TimelineEntry {
    let date: Date
    let aqi: AQI?
}

struct AQIProvider: TimelineProvider {
    let loader = AQILoader()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), aqi: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        loader.closestAQIOrCached { result in
            let currentDate = Date()
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
            let entry = SimpleEntry(date: currentDate, aqi: try? result.get())
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

private extension AQI {
    static let placeholder = AQI(value: 42, distance: 100, date: Date())
}
