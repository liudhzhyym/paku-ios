//
//  UIImage+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/30/20.
//

import UIKit

extension UIImage {
    convenience init(symbol: String, size: CGFloat, weight: UIImage.SymbolWeight) {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        self.init(systemName: symbol, withConfiguration: config)!
    }
}
