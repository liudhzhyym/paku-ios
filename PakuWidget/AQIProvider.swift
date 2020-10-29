//
//  AQIProvider.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import CoreLocation
import Solar
import WidgetKit

struct SimpleEntry: TimelineEntry {
    struct Info {
        var sensor: Sensor
        var distance: CLLocationDistance
    }

    let date: Date
    let info: Info?

    var isDaytime: Bool {
        true
    }
}

struct AQIProvider: TimelineProvider {
    let loader = AQILoader()

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), info: .init(sensor: .placeholder, distance: 42))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = placeholder(in: context)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        LocationManager.shared.requestLocation { result in
            if let location = try? result.get() {
                loader.loadSensor(near: location) { result in
                    DispatchQueue.main.async {
                        let currentDate = Date()
                        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!

                        let info: SimpleEntry.Info? = {
                            if let sensor = try? result.get() {
                                return SimpleEntry.Info(
                                    sensor: sensor,
                                    distance: sensor.info.location.distance(from: location)
                                )
                            } else {
                                return nil
                            }
                        }()

                        let entry = SimpleEntry(date: currentDate, info: info)
                        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                        completion(timeline)
                    }
                }
            }
        }
    }
}
