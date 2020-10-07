//
//  AQIIndicatorBar.swift
//  aqi-wtf
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
                let gradient = Gradient(colors: AQIClass.allCases.map(\.color).map(Color.init))
                let linearGradient = LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)

                Capsule()
                    .strokeBorder(Color.white)
                    .background(Capsule().fill(linearGradient))
                    .frame(height: 8)

                let frame = geometry.frame(in: .local)
                let maxAQI = AQIClass.allCases.last!
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
            .strokeBorder(Color.white)
            .background(Circle().fill(Color(color)))
    }
}

struct AQIIndicatorBar_Previews: PreviewProvider {
    static var previews: some View {
        AQIIndicatorBar(aqi: 20).frame(width: 100)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
