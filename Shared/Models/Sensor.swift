//
//  SensorData.swift
//  Paku
//
//  Created by Kyle Bashour on 10/20/20.
//

import AnyCodable
import Foundation

struct Sensor: Codable, Equatable {
    enum InitializerError: Error {
        case noResults
        case failedToParse
    }

    struct ParticleInfo: Codable, Equatable {
        var p_0_3_um: Double
        var p_0_5_um: Double
        var p_1_0_um: Double
        var p_2_5_um: Double
        var p_5_0_um: Double
        var p_10_0_um: Double
        var pm1_0_cf_1: Double
        var pm2_5_cf_1: Double
        var pm10_0_cf_1: Double
        var pm1_0_atm: Double
        var pm2_5_atm: Double
        var pm10_0_atm: Double

        init?(fields: [String: AnyCodable]) {
            guard let p_0_3_um = fields["p_0_3_um"]?.doubleValue,
                  let p_0_5_um = fields["p_0_5_um"]?.doubleValue,
                  let p_1_0_um = fields["p_1_0_um"]?.doubleValue,
                  let p_2_5_um = fields["p_2_5_um"]?.doubleValue,
                  let p_5_0_um = fields["p_5_0_um"]?.doubleValue,
                  let p_10_0_um = fields["p_10_0_um"]?.doubleValue,
                  let pm1_0_cf_1 = fields["pm1_0_cf_1"]?.doubleValue,
                  let pm2_5_cf_1 = fields["pm2_5_cf_1"]?.doubleValue,
                  let pm10_0_cf_1 = fields["pm10_0_cf_1"]?.doubleValue,
                  let pm1_0_atm = fields["pm1_0_atm"]?.doubleValue,
                  let pm2_5_atm = fields["pm2_5_atm"]?.doubleValue,
                  let pm10_0_atm = fields["pm10_0_atm"]?.doubleValue
            else {
                return nil
            }

            self.p_0_3_um = p_0_3_um
            self.p_0_5_um = p_0_5_um
            self.p_1_0_um = p_1_0_um
            self.p_2_5_um = p_2_5_um
            self.p_5_0_um = p_5_0_um
            self.p_10_0_um = p_10_0_um
            self.pm1_0_cf_1 = pm1_0_cf_1
            self.pm2_5_cf_1 = pm2_5_cf_1
            self.pm10_0_cf_1 = pm10_0_cf_1
            self.pm1_0_atm = pm1_0_atm
            self.pm2_5_atm = pm2_5_atm
            self.pm10_0_atm = pm10_0_atm
        }
    }

    let info: SensorInfo
    let age: Date
    let humidity: Double

    let particleInfo: [ParticleInfo]

    init(results: [[String: AnyCodable]], info: SensorInfo) throws {
        guard let parent = results.first(where: { $0["ParentID"] == nil }) else {
            throw InitializerError.noResults
        }

        self.info = info

        guard let age = parent["AGE"]?.intValue,
              let humidity = parent["humidity"]?.doubleValue
        else {
            throw InitializerError.failedToParse
        }

        self.age = Calendar.current.date(byAdding: .minute, value: -age, to: Date())!
        self.humidity = humidity
        self.particleInfo = results.compactMap(ParticleInfo.init)
    }

    func aqiValue(for conversion: AQIConversion = .EPA) -> Double {
        switch conversion {
        case .none:
            return aqiFrom(pm: average_pm2_5_cf_1)
        case .AQAndU:
            return aqanduAQI
        case .EPA:
            return epaAQI
        }
    }

    func aqiCategory(for conversion: AQIConversion = .EPA) -> AQICategory {
        return AQICategory(aqi: aqiValue(for: conversion))
    }

    // AQI Properties

    private var aqanduAQI: Double {
        aqiFrom(pm: 0.778 * average_pm2_5_cf_1 + 2.65)
    }

    private var epaAQI: Double {
        aqiFrom(pm: (0.534 * average_pm2_5_cf_1) - (0.0844 * humidity) + 5.604);
    }

    private var average_pm2_5_cf_1: Double {
        particleInfo.reduce(0, { $0 + $1.pm2_5_cf_1 }) / Double(particleInfo.count)
    }

    private func aqiFrom(pm: Double) -> Double {
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
            return pm
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
