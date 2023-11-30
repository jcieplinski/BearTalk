//
//  BodyState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct BodyState: Codable, Equatable {
    var doorLocks: String
    var frontCargo: String
    let rearCargo: String
    let frontLeftDoor: String
    let frontRightDoor: String
    let rearLeftDoor: String
    let rearRightDoor: String
    var chargePortState: String
    let walkawayLockSts: String
    let accessTypeSts: String
}
