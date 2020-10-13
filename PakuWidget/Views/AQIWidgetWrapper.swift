//
//  AQIWidgetWrapper.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit

struct AQIWidgetWrapper<Wrapped: View>: View {
    var entry: SimpleEntry
    var build: (AQI) -> Wrapped

    var body: some View {
        if let aqi = entry.aqi {
            build(aqi)
                .environment(\.isDayTime, entry.isDaytime)
        } else {
            ZStack {
                SkyView(category: .good)
                    .environment(\.isDayTime, entry.isDaytime)
                HStack {
                    VStack {
                        Spacer()
                        Text("We couldn’t load anything 😕 try opening the app")
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding()
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct AQIWidgetWrapper_Previews: PreviewProvider {
    static var previews: some View {
        AQIWidgetWrapper(entry: SimpleEntry(date: Date(), aqi: nil)) { aqi in
            AQIBarWidgetView(aqi: aqi)
        }
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
