//
//  Sensor.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import AnyCodable
import CoreLocation
import Foundation

struct SensorInfo: Equatable, Codable {
    enum InitializerError: Error {
        case failedToParse
    }

    let id: Int
    let label: String
    let isOutdoor: Bool
    let age: Int
    let lat: Double
    let lon: Double

    var location: CLLocation {
        CLLocation(latitude: lat, longitude: lon)
    }

    init(fields: [String: Int], data: [AnyCodable]) throws {
        guard let idIndex = fields["ID"],
              let labelIndex = fields["Label"],
              let latIndex = fields["Lat"],
              let lonIndex = fields["Lon"],
              let typeIndex = fields["Type"],
              let ageIndex = fields["age"],
              let id = data[idIndex].intValue,
              let lat = data[latIndex].doubleValue,
              let lon = data[lonIndex].doubleValue,
              let label = data[labelIndex].string,
              let type = data[typeIndex].intValue,
              let age = data[ageIndex].intValue
        else {
            throw InitializerError.failedToParse
        }

        self.id = id
        self.label = label
        self.isOutdoor = type == 0
        self.age = age
        self.lat = lat
        self.lon = lon
    }
}