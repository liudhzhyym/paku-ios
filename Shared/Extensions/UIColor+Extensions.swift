//
//  UIColor+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import UIKit

extension UIColor {
    static let mapButton = UIColor { traits in
        switch traits.userInterfaceStyle {
        case .dark: return .white
        default: return .systemBlue
        }
    }

    static let mapSeparator = UIColor { traits in
        switch traits.userInterfaceStyle {
        case .dark: return UIColor.white.withAlphaComponent(0.4)
        default: return .opaqueSeparator
        }
    }

    var luminance: CGFloat {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: nil)

        let colors = [red, green, blue]
            .map { c -> CGFloat in
                if c <= 0.03928 {
                    return c / 12.92
                } else {
                    return pow((c + 0.055) / 1.055, 2.4)
                }
            }

        return (0.2126 * colors[0]) + (0.7152 * colors[1]) + (0.0722 * colors[2])
    }

    var isLight: Bool {
        return luminance > 0.179
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

    // From https://stackoverflow.com/questions/22868182/uicolor-transition-based-on-progress-value
    func interpolateHSVColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor {
         var f = max(0, fraction)
         f = min(1, fraction)
         var h1: CGFloat = 0, s1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
         self.getHue(&h1, saturation: &s1, brightness: &b1, alpha: &a1)
         var h2: CGFloat = 0, s2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
         end.getHue(&h2, saturation: &s2, brightness: &b2, alpha: &a2)
         let h = h1 + (h2 - h1) * f
         let s = s1 + (s2 - s1) * f
         let b = b1 + (b2 - b1) * f
         let a = a1 + (a2 - a1) * f
         return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
     }
}
