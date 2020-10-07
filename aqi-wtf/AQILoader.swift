//
//  AQILoader.swift
//  aqi-wtf
//
//  Created by Kyle Bashour on 10/1/20.
//

import AnyCodable
import CoreLocation
import Foundation
import SwiftLocation
import UIKit

let encoder = JSONEncoder()
let decoder = JSONDecoder()

enum SensorInitializerError: Error {
    case failedToParse
    case irrelevant
}

struct Sensor: Codable {
    let id: Int
    let age: Int
    let lat: Double
    let lon: Double

    var location: CLLocation { CLLocation(latitude: lat, longitude: lon) }

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
        self.lat = lat
        self.lon = lon
    }
}

struct AQI: Codable {
    let value: Double
    let distance: Double
    let date: Date

    var `class`: AQIClass {
        AQIClass(aqi: value)!
    }
}

enum AQIClass {
    case veryHazardous
    case hazardous
    case veryUnhealthy
    case unhealthy
    case unhealthyForSensitiveGroups
    case moderate
    case good

    init?(aqi: Double) {
        switch aqi {
        case 401...: self = .veryHazardous
        case 301...: self = .hazardous
        case 201...: self = .veryUnhealthy
        case 151...: self = .unhealthy
        case 101...: self = .unhealthyForSensitiveGroups
        case 51...: self = .moderate
        case 0...: self = .good
        default: return nil
        }
    }

    var description: String {
        switch self {
        case .veryHazardous:
            return "Very hazardous"
        case .hazardous:
            return "Hazardous"
        case .veryUnhealthy:
            return "Very unhealthy"
        case .unhealthy:
            return "Unhealthy"
        case .unhealthyForSensitiveGroups:
            return "Unhealthy for sensitive groups"
        case .moderate:
            return "Moderate"
        case .good:
            return "Good"
        }
    }

    var color: UIColor {
        switch self {
        case .veryHazardous:
            return UIColor(displayP3Red: 0.451, green: 0.078, blue: 0.145, alpha: 1)
        case .hazardous:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .veryUnhealthy:
            return UIColor(displayP3Red: 0.549, green: 0.102, blue: 0.294, alpha: 1)
        case .unhealthy:
            return UIColor(displayP3Red: 0.918, green: 0.2, blue: 0.141, alpha: 1)
        case .unhealthyForSensitiveGroups:
            return UIColor(displayP3Red: 0.937, green: 0.522, blue: 0.2, alpha: 1)
        case .moderate:
            return UIColor(displayP3Red: 1, green: 1, blue: 0.333, alpha: 1)
        case .good:
            return UIColor(displayP3Red: 0.408, green: 0.882, blue: 0.263, alpha: 1)
        }
    }

    var textColor: UIColor {
        switch self {
        case .veryHazardous, .hazardous, .veryUnhealthy, .unhealthy:
            return .white
        default:
            return .black
        }
    }
}

struct SensorsResponse: Codable {
    let fields: [String]
    let data: [[AnyCodable]]
}

struct SensorResponse: Codable {
    let results: [[String: AnyCodable]]
}

enum AQILoaderError: Error {
    case failedToDecode(Error)
    case invalidAQI
    case unknownError
}

struct CachedValue<T: Codable>: Codable {
    let date: Date
    let value: T
}

struct ExpiringCache {
    static func cache<T: Codable>(_ value: T, forKey key: String) {
        let cached = CachedValue(date: Date(), value: value)
        UserDefaults.shared.set(codable: cached, forKey: key)
    }

    static func value<T: Codable>(_ type: T.Type, forKey key: String, expiration: TimeInterval) -> CachedValue<T>? {
        guard let cached = UserDefaults.shared.codable(CachedValue<T>.self, forKey: key),
              Date().timeIntervalSince(cached.date) < expiration else {
            return nil
        }

        return cached
    }
}

struct AQILoader {
    let aqiKey = "aqi"
    let sensorsKey = "sensors"

    private func loadSensors(completion: @escaping (Result<[Sensor], Error>) -> Void) {
        if let cached = ExpiringCache.value([Sensor].self, forKey: sensorsKey, expiration: 24 * 60 * 60) {
            return completion(.success(cached.value))
        }

        let url = URL(string: "https://www.purpleair.com/data.json?opt=1/mAQI/a10/cC0&fetch=true&fields=,")!

        URLSession.shared.load(SensorsResponse.self, from: url) { result in
            switch result {
            case .success(let response):
                let fields = response.fields.enumerated().reduce(into: [:]) { result, field in
                    result[field.element] = field.offset
                }

                let sensors = response.data.compactMap {
                    Sensor(fields: fields, data: $0)
                }

                ExpiringCache.cache(sensors, forKey: sensorsKey)
                completion(.success(sensors))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadAQI(from sensor: Sensor, completion: @escaping (Result<Double, Error>) -> Void) {
        let url = URL(string: "https://www.purpleair.com/json?show=\(sensor.id)")!
        URLSession.shared.load(SensorResponse.self, from: url) { result in
            switch result {
            case .success(let response):
                let pm2_5Values = response.results.compactMap(pm2_5)
                let pm2_5 = pm2_5Values.reduce(0, +) / Double(pm2_5Values.count)

                if let aqi = aqanduAQIfrom(pm: pm2_5) {
                    completion(.success(aqi))
                } else {
                    completion(.failure(AQILoaderError.invalidAQI))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func loadClosestAQI(completion: @escaping (Result<AQI, Error>) -> Void) {
        loadSensors { result in
            switch result {
            case .success(let sensors):
                LocationManager.shared.locateFromGPS(.oneShot, accuracy: .block) { result in
                    switch result {
                    case .success(let location):
                        let closest = closestSensor(in: sensors, from: location)
                        loadAQI(from: closest.sensor) { result in
                            switch result {
                            case .success(let aqi):
                                let aqi = AQI(value: aqi, distance: closest.distance, date: Date())
                                ExpiringCache.cache(aqi, forKey: aqiKey)
                                completion(.success(aqi))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func closestAQIOrCached(completion: @escaping (Result<AQI, Error>) -> Void) {
        loadClosestAQI { result in
            switch result {
            case .success(let aqi):
                completion(.success(aqi))
            case .failure(let error):
                if let cached = ExpiringCache.value(AQI.self, forKey: aqiKey, expiration: 60 * 60) {
                    completion(.success(cached.value))
                } else {
                    completion(.failure(error))
                }
            }
        }
    }

    private func closestSensor(in sensors: [Sensor], from location: CLLocation) -> (sensor: Sensor, distance: Double) {
        var closest: (sensor: Sensor?, distance: Double) = (nil, .greatestFiniteMagnitude)
        for sensor in sensors {
            let distance = sensor.location.distance(from: location)
            if distance < closest.distance {
                closest = (sensor, distance)
            }
        }
        return (closest.sensor!, closest.distance)
    }

    private func pm2_5(from data: [String: AnyCodable]) -> Double? {
        func isBusted() -> Bool {
            for field in [
                "p_0_3_um",
                "p_0_5_um",
                "p_1_0_um",
                "p_2_5_um",
                "p_5_0_um",
                "p_10_0_um",
                "pm1_0_cf_1",
                "pm2_5_cf_1",
                "pm10_0_cf_1",
                "pm1_0_atm",
                "pm2_5_atm",
                "pm10_0_atm",
            ] {
                if let value = data[field]?.value as? String, value != "0.0" {
                    return false
                }
            }

            return true
        }

        if isBusted() {
            return nil
        }

        guard let value = data["PM2_5Value"]?.value as? String, let double = Double(value) else {
            return nil
        }

        return double
    }

    private func aqanduAQIfrom(pm: Double) -> Double? {
        aqiFrom(pm: 0.778 * pm + 2.65)
    }

    private func aqiFrom(pm: Double) -> Double? {
        if pm.isNaN { return nil }
        if pm < 0 { return pm }
        if pm > 1000 { return nil }

        if pm > 350.5 {
            return calcAQI(Cp: pm, Ih: 500, Il: 401, BPh: 500, BPl: 350.5)
        } else if pm > 250.5 {
            return calcAQI(Cp: pm, Ih: 400, Il: 301, BPh: 350.4, BPl: 250.5)
        } else if pm > 150.5 {
            return calcAQI(Cp: pm, Ih: 300, Il: 201, BPh: 250.4, BPl: 150.5)
        } else if pm > 55.5 {
            return calcAQI(Cp: pm, Ih: 200, Il: 151, BPh: 150.4, BPl: 55.5)
        } else if pm > 35.5 {
            return calcAQI(Cp: pm, Ih: 150, Il: 101, BPh: 55.4, BPl: 35.5)
        } else if pm > 12.1 {
            return calcAQI(Cp: pm, Ih: 100, Il: 51, BPh: 35.4, BPl: 12.1)
        } else if pm >= 0 {
            return calcAQI(Cp: pm, Ih: 50, Il: 0, BPh: 12, BPl: 0)
        } else {
            return nil
        }
    }

    private func calcAQI(Cp: Double, Ih: Double, Il: Double, BPh: Double, BPl: Double) -> Double {
        // The AQI equation https://forum.airnowtech.org/t/the-aqi-equation/169
        let a = Ih - Il;
        let b = BPh - BPl;
        let c = Cp - BPl;
        return round((a / b) * c + Il)
    }
}

extension URLSession {
    func load<T: Decodable>(_ type: T.Type, from url: URL, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data {
                do {
                    let response = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(AQILoaderError.failedToDecode(error)))
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(AQILoaderError.unknownError))
                }
            }
        }.resume()
    }
}

extension UserDefaults {

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()

    static let shared = UserDefaults(suiteName: "group.com.kylebashour.aqi-wtf")!

    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key),
              let decoded = try? Self.decoder.decode(T.self, from: data)
        else {
            return nil
        }

        return decoded
    }

    func set<T: Codable>(codable value: T, forKey key: String) {
        set(try? Self.encoder.encode(value), forKey: key)
    }
}
