//
//  MKDistanceFormatter+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import MapKit

extension MKDistanceFormatter {
    static let abbreviated: MKDistanceFormatter = {
        let formatter = MKDistanceFormatter()
        formatter.unitStyle = .abbreviated
        return formatter
    }()
}
