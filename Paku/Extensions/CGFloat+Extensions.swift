//
//  CGFloat+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/19/20.
//

import UIKit

extension CGFloat {
    static var pixel: CGFloat {
        1.0 / UIScreen.main.scale
    }
}
