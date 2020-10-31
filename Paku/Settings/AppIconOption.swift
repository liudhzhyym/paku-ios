//
//  AppIconOption.swift
//  Paku
//
//  Created by Kyle Bashour on 10/30/20.
//

import Foundation

struct AppIconOption {
    let name: String
    let key: String?

    var imageName: String {
        key ?? "AppIcon-Default"
    }

    static let all: [AppIconOption] = [
        AppIconOption(name: "Default", key: nil),
        AppIconOption(name: "Purple Rain", key: "AppIcon-PurpleRain"),
        AppIconOption(name: "Black & White", key: "AppIcon-BlackWhite"),
        AppIconOption(name: "Paku Paku", key: "AppIcon-Pacman"),
    ]

    static func name(for key: String?) -> String? {
        all.first { $0.key == key }?.name
    }
}
