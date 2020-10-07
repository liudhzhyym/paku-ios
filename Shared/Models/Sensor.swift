//
//  Sensor.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import AnyCodable
import CoreLocation
import Foundation

struct Sensor: Codable {
    enum InitializerError: Error {
        case failedToParse
        case irrelevant
    }

    let id: Int
    let age: Int
    let lat: Double
    let lon: Double

    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    init(fields: [String: Int], data: [AnyCodable]) throws {
        guard let idIndex = fields["ID"],
              let ageIndex = fields["age"],
              let latIndex = fields["Lat"],
              let lonIndex = fields["Lon"],
              let indoorIndex = fields["Type"],
              let id = data[idIndex].value as? Int,
              let age = data[ageIndex].value as? Int,
              let lat = data[latIndex].value as? Double,
              let lon = data[lonIndex].value as? Double,
              let indoor = data[indoorIndex].value as? Int
        else {
            throw InitializerError.failedToParse
        }

        guard indoor == 0 && age < 5 else {
            throw InitializerError.irrelevant
        }

        self.id = id
        self.age = age
        self.lat = lat
        self.lon = lon
    }
}
