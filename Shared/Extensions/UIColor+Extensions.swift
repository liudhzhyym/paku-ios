//
//  UIColor+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit

extension UIColor {
    static let customPurple = UIColor(hex: "9D05C3")

    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
    }

    var isLight: Bool {
        return luminance >= 0.6
    }


    // From https://stackoverflow.com/questions/22868182/uicolor-transition-based-on-progress-value
    public convenience init(hex: String) {
        let r, g, b: CGFloat

        if hex.count == 6 {
            let scanner = Scanner(string: hex)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                b = CGFloat((hexNumber & 0x0000ff)) / 255

                self.init(displayP3Red: r, green: g, blue: b, alpha: 1)
                return
            }
        }

        fatalError("Invalid color format")
    }

    // From https://stackoverflow.com/questions/22868182/uicolor-transition-based-on-progress-value
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        let f = min(max(0, fraction), 1)

        guard let c1 = self.cgColor.components, let c2 = end.cgColor.components else { return nil }

        let r: CGFloat = CGFloat(c1[0] + (c2[0] - c1[0]) * f)
        let g: CGFloat = CGFloat(c1[1] + (c2[1] - c1[1]) * f)
        let b: CGFloat = CGFloat(c1[2] + (c2[2] - c1[2]) * f)
        let a: CGFloat = CGFloat(c1[3] + (c2[3] - c1[3]) * f)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
