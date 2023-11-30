//
//  Vehicle.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct Vehicle: Codable, Equatable {
    let vehicleId: String
    let accessLevel: String
    let vehicleConfig: VehicleConfig
    var vehicleState: VehicleState
}
