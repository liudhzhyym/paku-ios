//
//  Sensor+Placeholder.swift
//  PakuWidget
//
//  Created by Kyle Bashour on 10/25/20.
//

import AnyCodable
import Foundation

extension SensorInfo {
    static let placeholder = SensorInfo(id: 0, label: "Paku", isOutdoor: true, lat: 37, lon: -122)

    init(id: Int, label: String, isOutdoor: Bool, lat: Double, lon: Double) {
        self.id = id
        self.label = label
        self.isOutdoor = isOutdoor
        self.lat = lat
        self.lon = lon
    }
}

extension Sensor {
    static let placeholder = Sensor(
        info: .placeholder,
        age: Date().addingTimeInterval(-5),
        humidity: 5,
        particleInfo: [
            Sensor.ParticleInfo(fields: [
                "p_0_3_um": AnyCodable(2.0),
                "p_0_5_um": AnyCodable(2.0),
                "p_1_0_um": AnyCodable(2.0),
                "p_2_5_um": AnyCodable(2.0),
                "p_5_0_um": AnyCodable(2.0),
                "p_10_0_um": AnyCodable(2.0),
                "pm1_0_cf_1": AnyCodable(2.0),
                "pm2_5_cf_1": AnyCodable(9.0),
                "pm10_0_cf_1": AnyCodable(2.0),
                "pm1_0_atm": AnyCodable(2.0),
                "pm2_5_atm": AnyCodable(2.0),
                "pm10_0_atm": AnyCodable(2.0),
            ])!
        ]
    )

    init(info: SensorInfo, age: Date, humidity: Double, particleInfo: [Sensor.ParticleInfo]) {
        self.info = info
        self.age = age
        self.humidity = humidity
        self.particleInfo = particleInfo
    }
}
