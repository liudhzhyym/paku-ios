//
//  AnyCodable+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/20/20.
//

import AnyCodable
import Foundation

extension AnyCodable {
    var doubleValue: Double? {
        value as? Double ?? string.flatMap(Double.init)
    }

    var intValue: Int? {
        value as? Int
    }

    var string: String? {
        value as? String
    }
}
