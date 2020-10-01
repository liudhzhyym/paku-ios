//
//  AQILoader.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import AnyCodable
import CoreLocation
import Foundation

enum SensorInitializerError: Error {
    case failedToParse
    case irrelevant
}

struct Sensor {
    let id: Int
    let age: Int
    let coordinate: CLLocationCoordinate2D

    init?(fields: [String: Int], data: [AnyCodable]){
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
            return nil
        }

        guard indoor == 0 && age < 5 else {
            return nil
        }

        self.id = id
        self.age = age
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

struct AQI {
    let value: Int
    let guidance: [String]
}

struct SensorsResponse: Codable {
    let fields: [String]
    let data: [[AnyCodable]]
}

enum AQILoaderError: Error {
    case failedToDecode
    case unknownError
}

struct AQILoader {
    private let decoder = JSONDecoder()

    func loadSensors(completion: @escaping (Result<[Sensor], Error>) -> Void) {
        let url = URL(string: "https://www.purpleair.com/data.json?opt=1/mAQI/a10/cC0&fetch=true&fields=,")!

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try decoder.decode(SensorsResponse.self, from: data)

                    let fields = response.fields.enumerated().reduce(into: [:]) { result, field in
                        result[field.element] = field.offset
                    }

                    let sensors = response.data.compactMap {
                        Sensor(fields: fields, data: $0)
                    }

                    completion(.success(sensors))
                } catch {
                    completion(.failure(AQILoaderError.failedToDecode))
                }
            } else {
                completion(.failure(AQILoaderError.unknownError))
            }
        }.resume()
    }

    func loadAQI(from sensor: Sensor, completion: (AQI) -> Void) {

    }
}
