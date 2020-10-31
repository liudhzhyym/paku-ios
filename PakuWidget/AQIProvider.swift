//
//  AQIProvider.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import CoreLocation
import WidgetKit

struct SimpleEntry: TimelineEntry {
    struct Info {
        var sensor: Sensor
        var distance: CLLocationDistance
    }

    let date: Date
    let info: Info?
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
        let currentDate = Date()

        func completeWithFailure() {
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
            let entry = SimpleEntry(date: currentDate, info: nil)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            DispatchQueue.main.async {
                completion(timeline)
            }
        }

        LocationManager.shared.requestLocation { result in
            do {
                let location = try result.get()
                loader.loadOutdoorSensor(near: location) { result in
                    do {
                        let sensor = try result.get()
                        let info = SimpleEntry.Info(
                            sensor: sensor,
                            distance: sensor.info.location.distance(from: location)
                        )

                        let refreshDate = Calendar.current.date(byAdding: .minute, value: 10, to: currentDate)!
                        let entry = SimpleEntry(date: currentDate, info: info)
                        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))

                        DispatchQueue.main.async {
                            completion(timeline)
                        }
                    } catch {
                        logger.error("Widget failed to load sensor")
                        completeWithFailure()
                    }
                }
            } catch {
                logger.error("Widget failed to update location")
                completeWithFailure()
            }
        }
    }
}
