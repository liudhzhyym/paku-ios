//
//  AQIEntryView.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import SwiftUI

struct AQIEntryView: View {
    var aqi: AQI

    var body: some View {
        ZStack {
            Color(aqi.class.color)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(aqi.value))")
                        .font(.headline)
                        .foregroundColor(Color(aqi.class.textColor))

                    Text(aqi.date, style: .time)
                        .font(Font.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(Color(aqi.class.textColor))


                    Spacer()

                    Text(aqi.class.description)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(aqi.class.textColor))
                }

                Spacer()
            }.padding()
        }
    }
}

struct MessageView: View {
    var message: String

    var body: some View {
        Text(message).padding()
    }
}
