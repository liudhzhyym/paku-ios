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
        let cases = AQIClass.barIndicatorCases
        let maxAQI = cases.last!
        let barFraction = min(aqi, maxAQI.rawValue) / maxAQI.rawValue

        let barPosition = CGFloat(barFraction * Double(cases.count - 1))

        let lowerIndex = Int(barPosition.rounded(.down))
        let upperIndex = Int(barPosition.rounded(.up))

        let lowerColor = cases[lowerIndex].color
        let upperColor = cases[upperIndex].color

        let colorFraction = barPosition - CGFloat(lowerIndex)

        return lowerColor.interpolateRGBColorTo(upperColor, fraction: colorFraction)!
    }
}

struct AQIIndicatorBar_Previews: PreviewProvider {
    static var previews: some View {
        AQIIndicatorBar(aqi: 60).frame(width: 140)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
