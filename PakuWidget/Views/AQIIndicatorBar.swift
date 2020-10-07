//
//  AQIIndicatorBar.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/6/20.
//

import SwiftUI
import WidgetKit

struct AQIIndicatorBar: View {

    var aqi: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                let AQICases = AQIClass.barIndicatorCases
                let gradient = Gradient(colors: AQICases.map(\.color).map(Color.init))
                let linearGradient = LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)

                Capsule()
                    .strokeBorder(Color.white)
                    .background(Capsule().fill(linearGradient))
                    .frame(height: 8)

                let frame = geometry.frame(in: .local)
                let maxAQI = AQICases.last!
                let percent = min(aqi, maxAQI.rawValue) / maxAQI.rawValue

                let circleDimension: CGFloat = 12
                let circleX = CGFloat(percent) * (frame.width - circleDimension) + circleDimension / 2

                circle()
                    .frame(width: circleDimension, height: circleDimension)
                    .position(x: circleX, y: frame.midY)
                    .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 1)
            }
        }.frame(height: 10)
    }

    func circle() -> some View {
        let color = AQIClass.color(at: aqi)
        return Circle()
            .strokeBorder(Color.white, lineWidth: 1)
            .background(Circle().fill(Color(color)))
    }
}

private extension AQIClass {
    static var barIndicatorCases: [AQIClass] {
        allCases.dropLast()
    }

    var color: UIColor {
        switch self {
        case .veryHazardous:
            return UIColor(hex: "76212E")
        case .hazardous:
            return UIColor(hex: "89117A")
        case .veryUnhealthy:
            return UIColor(hex: "9D05C3")
        case .unhealthy:
            return UIColor(hex: "AD00FA")
        case .unhealthyForSensitiveGroups:
            return UIColor(hex: "FF4444")
        case .moderate:
            return UIColor(hex: "FFC50B")
        case .good:
            return UIColor(hex: "35C759")
        }
    }

    static func color(at aqi: Double) -> UIColor {
        let offsetAQI = aqi + AQIClass.good.rawValue / 2
        let upper = AQIClass(aqi: offsetAQI)

        guard let index = AQIClass.barIndicatorCases.firstIndex(of: upper), index > 0 else {
            return upper.color
        }

        let lower = AQIClass.barIndicatorCases[index - 1]
        let fraction = (offsetAQI - lower.rawValue) / (upper.rawValue - lower.rawValue)

        return lower.color.interpolateRGBColorTo(upper.color, fraction: CGFloat(fraction))!
    }
}

struct AQIIndicatorBar_Previews: PreviewProvider {
    static var previews: some View {
        AQIIndicatorBar(aqi: 20).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 50).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 80).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 102).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 150).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 250).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: 350).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))

        AQIIndicatorBar(aqi: AQIClass.veryHazardous.rawValue).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
