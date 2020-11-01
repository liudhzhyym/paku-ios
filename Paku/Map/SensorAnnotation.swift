//
//  AQIAnnotation.swift
//  Paku
//
//  Created by Kyle Bashour on 10/9/20.
//

import MapKit

class SensorAnnotation: NSObject, MKAnnotation {

    // Must be KVO compliant, hence the @objc dynamic
    @objc dynamic var coordinate: CLLocationCoordinate2D

    var sensor: Sensor

    var shouldAnimateDisplay: Bool = true

    init(sensor: Sensor) {
        self.coordinate = sensor.info.location.coordinate
        self.sensor = sensor
        super.init()
    }
}
