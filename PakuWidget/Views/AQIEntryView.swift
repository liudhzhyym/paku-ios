//
//  AQIEntryView.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import WidgetKit
import SwiftUI
import MapKit

struct AQIEntryView: View {
    var info: SimpleEntry.Info

    var body: some View {
        ZStack {
            let category = info.sensor.aqiCategory()
            let sensor = info.sensor

            Color(category.color)

            HStack {
                VStack(alignment: .leading) {
                    Text("\(Int(sensor.aqiValue()))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color(category.textColor))

                    (Text(sensor.age, style: .time) + Text("\n\(MKDistanceFormatter.abbreviated.string(fromDistance: info.distance)) away"))
                        .font(Font.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(category.textColor))

                    Spacer()

                    Text(category.description)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(Color(category.textColor))
                }

                Spacer()
            }.padding()
        }
    }
}

private extension AQICategory {
    var color: UIColor {
        switch self {
        case .hazardous:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .veryUnhealthy:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .unhealthy:
            return UIColor(displayP3Red: 0.918, green: 0.2, blue: 0.141, alpha: 1)
        case .unhealthyForSensitiveGroups:
            return UIColor(displayP3Red: 0.937, green: 0.522, blue: 0.2, alpha: 1)
        case .moderate:
            return UIColor(displayP3Red: 1, green: 1, blue: 0.333, alpha: 1)
        case .good:
            return UIColor(displayP3Red: 0.408, green: 0.882, blue: 0.263, alpha: 1)
        }
    }

    var textColor: UIColor {
        switch self {
        case .hazardous, .veryUnhealthy, .unhealthy:
            return .white
        default:
            return .black
        }
    }
}

//struct AQIEntryView_Previews: PreviewProvider {
//    static var previews: some View {
//        AQIEntryView(aqi: .init(value: 20, distance: 10, date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
