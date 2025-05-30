//
//  UserDefaults.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/30/25.
//

import Foundation

extension UserDefaults {
    static var appGroup: UserDefaults {
        UserDefaults(suiteName: "group.com.joecieplinski.bearTalk") ?? .standard
    }
}
