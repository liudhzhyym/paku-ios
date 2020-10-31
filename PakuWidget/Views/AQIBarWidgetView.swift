//
//  AQIBarWidget.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit
import MapKit

struct AQIBarWidgetView: View {
    var info: SimpleEntry.Info

    @Environment(\.redactionReasons) var redactionReasons

    var body: some View {
        ZStack {
            let sensor = info.sensor

            SkyView(category: sensor.aqiCategory())

            VStack(alignment: .leading) {
                Text("Air Quality")
                    .font(.system(size: 15, weight: .medium))

                Text("\(Int(sensor.aqiValue()))")
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.5)

                HStack(spacing: 5) {
                    (Text(MKDistanceFormatter.abbreviated.string(fromDistance: info.distance)) + Text(" away"))
                        .font(.system(size: 13, weight: .medium))
                    if !redactionReasons.contains(.placeholder) {
                        Image(systemName: "location.fill").font(.system(size: 9))
                    }
                }

                (Text(sensor.age, style: .timer) + Text(" ago"))
                    .font(Font.system(size: 13, weight: .medium).monospacedDigit())

                Spacer()

                AQIIndicatorBar(aqi: sensor.aqiValue())
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct AQIBarWidget_Previews: PreviewProvider {
    static var previews: some View {
        AQIBarWidgetView(info: .init(sensor: .placeholder, distance: 33))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
