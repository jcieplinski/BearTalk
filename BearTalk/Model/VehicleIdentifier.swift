//
//  VehicleIdentifier.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import Foundation
import SwiftData

@Model
final class VehicleIdentifier: Identifiable {
    @Attribute(.unique) var id: String
    var nickname: String
    var snapshotData: Data?
    
    internal init(id: String, nickname: String, snapshotData: Data? = nil) {
        self.id = id
        self.nickname = nickname
        self.snapshotData = snapshotData
    }
}
