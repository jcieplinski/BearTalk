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
    let snapshotData: Data?
    
    internal init(
        id: String,
        nickname: String,
        snapshotData: Data? = nil
    ) {
        self.id = id
        self.nickname = nickname
        self.snapshotData = snapshotData
    }
    
    init(identifier: VehicleIdentifier) {
        self.id = identifier.id
        self.nickname = identifier.nickname
        self.snapshotData = identifier.snapshotData
    }
}
