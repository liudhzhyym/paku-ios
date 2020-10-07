//
//  NSAttributedString+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import Foundation

func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString {
    let result = NSMutableAttributedString()
    result.append(left)
    result.append(right)
    return result
}
