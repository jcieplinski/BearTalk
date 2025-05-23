//
//  VehicleIdentifierEntity.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftData
import AppIntents

struct VehicleIdentifierEntity: Identifiable, AppEntity {
    static let defaultQuery = VehicleIdentifierQuery()
    
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Vehicle"
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(nickname)")
    }
    
    let id: String
    let nickname: String
    
    internal init(
        id: String,
        nickname: String
    ) {
        self.id = id
        self.nickname = nickname
    }
    
    init(identifier: VehicleIdentifier) {
        self.id = identifier.id
        self.nickname = identifier.nickname
    }
}
