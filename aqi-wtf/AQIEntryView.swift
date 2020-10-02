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
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(aqi.class.textColor))

                    Text(aqi.date, style: .time)
                        .font(Font.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(aqi.class.textColor))


                    Spacer()

                    Text(aqi.class.description)
                        .font(.body)
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

struct AQIEntryView_Previews: PreviewProvider {
    static var previews: some View {
        AQIEntryView(aqi: .init(value: 20, distance: 10, date: Date()))
    }
}
