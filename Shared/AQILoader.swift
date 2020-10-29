//
//  AQILoader.swift
//  Paku
//
//  Created by Kyle Bashour on 10/1/20.
//

import AnyCodable
import CoreLocation
import Combine
import Foundation
import UIKit

class AQILoader: ObservableObject {

    enum AQILoaderError: Error {
        case failedToDecode(Error)
        case invalidAQI
        case unknownError
    }

    private struct SensorsResponse: Codable {
        let fields: [String]
        let data: [[AnyCodable]]
    }

    private struct SensorResponse: Codable {
        let results: [[String: AnyCodable]]
    }

    private struct CachedValue<T: Codable>: Codable {
        let date: Date
        let value: T
    }

    private struct ExpiringCache {
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

    private let sensorsKey = "sensors-v5"
    private func sensorKey(_ info: SensorInfo) -> String { "sensor\(info.id)" }

    func loadSensors(completion: @escaping (Result<[SensorInfo], Error>) -> Void) {
        if let cached = ExpiringCache.value([SensorInfo].self, forKey: sensorsKey, expiration: 24 * 60 * 60) {
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
                    try? SensorInfo(fields: fields, data: $0)
                }.filter {
                    $0.age < 5
                }

                if sensors.isEmpty {
                    completion(.failure(AQILoaderError.unknownError))
                } else {
                    ExpiringCache.cache(sensors, forKey: self.sensorsKey)
                    completion(.success(sensors))
                }
            case .failure(let error):
                if let cached = ExpiringCache.value([SensorInfo].self, forKey: self.sensorsKey, expiration: 5 * 24 * 60 * 60) {
                    return completion(.success(cached.value))
                } else {
                    return completion(.failure(error))
                }
            }
        }
    }

    func loadSensor(from info: SensorInfo, completion: @escaping (Result<Sensor, Error>) -> Void) {
        let url = URL(string: "https://www.purpleair.com/json?show=\(info.id)")!

        if let cached = ExpiringCache.value(Sensor.self, forKey: sensorKey(info), expiration: 60) {
            return completion(.success(cached.value))
        }

        URLSession.shared.load(SensorResponse.self, from: url) { result in
            switch result {
            case .success(let response):
                do {
                    let sensor = try Sensor(results: response.results, info: info)
                    ExpiringCache.cache(sensor, forKey: self.sensorKey(info))
                    completion(.success(sensor))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadSensor(near location: CLLocation, completion: @escaping (Result<Sensor, Error>) -> Void = { _ in }) {
        loadSensors { result in
            switch result {
            case .success(let sensors):

                let closest = self.closestSensor(in: sensors, from: location)

                self.loadSensor(from: closest.sensor) { result in
                    switch result {
                    case .success(let sensor):
                        completion(.success(sensor))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func closestSensor(in sensors: [SensorInfo], from location: CLLocation) -> (sensor: SensorInfo, distance: CLLocationDistance) {
        var closest: (sensor: SensorInfo?, distance: Double) = (nil, .greatestFiniteMagnitude)
        for sensor in sensors {
            let distance = sensor.location.distance(from: location)
            if distance < closest.distance && sensor.isOutdoor {
                closest = (sensor, distance)
            }
        }
        return (closest.sensor!, closest.distance)
    }
}
