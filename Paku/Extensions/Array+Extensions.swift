//
//  Array+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/10/20.
//

import Foundation

extension Array where Element: FloatingPoint {
    func median() -> Element {
        let sortedArray = sorted()
        if count % 2 != 0 {
            return sortedArray[count / 2]
        } else {
            return (sortedArray[count / 2] + sortedArray[count / 2 - 1]) / 2
        }
    }
}
