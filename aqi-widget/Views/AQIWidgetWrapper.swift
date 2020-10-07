//
//  AQIWidgetWrapper.swift
//  aqi-widgetExtension
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI

struct AQIWidgetWrapper<Wrapped: View>: View {
    var entry: SimpleEntry
    var build: (AQI) -> Wrapped

    var body: some View {
        if let aqi = entry.aqi {
            build(aqi)
        } else {
            HStack {
                VStack {
                    Text("We couldn't load anything 😕 try opening the app")
                        .font(.caption)
                        .padding()
                    Spacer()
                }
                Spacer()
            }
        }
    }
}
