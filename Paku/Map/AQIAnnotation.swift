//
//  AQIAnnotation.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import MapKit

class AQIAnnotation: NSObject, MKAnnotation {

    // Must be KVO compliant, hence the @objc dynamic
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var sensorID: Int

    var aqiValue: Double

    init(coordinate: CLLocationCoordinate2D, sensorID: Int) {
        self.coordinate = coordinate
        self.sensorID = sensorID
        self.aqiValue = Double(Int((2...32).randomElement()!))
        super.init()
    }
}
