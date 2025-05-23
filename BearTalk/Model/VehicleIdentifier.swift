//
//  VehicleIdentifier.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftData

@Model
final class VehicleIdentifier: Identifiable {
    @Attribute(.unique) var id: String
    var nickname: String
    
    internal init(id: String, nickname: String) {
        self.id = id
        self.nickname = nickname
    }
}
