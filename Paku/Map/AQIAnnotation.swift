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

    init(aqiValue: Double, coordinate: CLLocationCoordinate2D, sensorID: Int) {
        self.aqiValue = aqiValue
        self.coordinate = coordinate
        self.sensorID = sensorID
        super.init()
    }
}
