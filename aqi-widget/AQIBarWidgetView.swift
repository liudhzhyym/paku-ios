//
//  AQIBarWidget.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit
import MapKit

private let formatter: MKDistanceFormatter = {
    let formatter = MKDistanceFormatter()
    formatter.unitStyle = .abbreviated
    return formatter
}()

struct AQIBarWidgetView: View {
    var aqi: AQI

    var body: some View {
        ZStack {

            SkyView(aqi: aqi.class)

            VStack(alignment: .leading) {
                Text("Air Quality")
                    .font(.system(size: 15, weight: .medium))

                Text("\(Int(aqi.value))")
                    .font(.system(size: 42, weight: .light, design: .rounded))
                    .minimumScaleFactor(0.5)
                    .scaledToFit()


                Text(aqi.date, style: .time)
                    .font(.system(size: 13, weight: .medium))

                HStack(spacing: 5) {
                    Text(formatter.string(fromDistance: aqi.distance))
                        .font(.system(size: 13, weight: .medium))
                    Image(systemName: "location.fill").font(.system(size: 9))
                }

                Spacer()

                AQIIndicatorBar(aqi: aqi.value)
            }
            .foregroundColor(.white)
            .padding()
        }
    }
}

struct AQIBarWidget_Previews: PreviewProvider {
    static var previews: some View {
        AQIBarWidgetView(aqi: .init(value: 50, distance: 200, date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIBarWidgetView(aqi: .init(value: 0, distance: 2000, date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIBarWidgetView(aqi: .init(value: 600, distance: 10, date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))

    }
}
