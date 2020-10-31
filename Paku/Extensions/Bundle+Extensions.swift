//
//  Bundle+Extensions.swift
//  Paku
//
//  Created by Kyle Bashour on 10/31/20.
//

import Foundation

extension Bundle {
    func version() -> String {
        let dictionary = infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(build))"
    }
}
