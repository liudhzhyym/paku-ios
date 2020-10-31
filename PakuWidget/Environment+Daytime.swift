//
//  Environment+Daytime.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/12/20.
//

import SwiftUI

struct IsDayTimeKey: EnvironmentKey {
    static var defaultValue = true
}

extension EnvironmentValues {
    var isDayTime: Bool {
        get { self[IsDayTimeKey.self] }
        set { self[IsDayTimeKey.self] = newValue }
    }
}
