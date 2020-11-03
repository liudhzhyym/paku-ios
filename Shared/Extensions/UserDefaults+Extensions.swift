//
//  UserDefaults+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/6/20.
//

import Foundation

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

    var settings: Settings {
        get { UserDefaults.shared.codable(Settings.self, forKey: "user-settings") ?? Settings() }
        set { UserDefaults.shared.set(codable: newValue, forKey: "user-settings") }
    }

    var hiddenSensors: [SensorInfo] {
        get { UserDefaults.shared.codable([SensorInfo].self, forKey: "hidden-sensors") ?? [] }
        set { UserDefaults.shared.set(codable: newValue, forKey: "hidden-sensors") }
    }
}
