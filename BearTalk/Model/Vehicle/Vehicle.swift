//
//  Vehicle.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct Vehicle: Codable, Equatable {
    let vehicleId: String
    let accessLevel: AccessLevel
    var vehicleConfig: VehicleConfig
    var vehicleState: VehicleState

    static func example() -> Vehicle? {
        return nil
    }
}

enum AccessLevel: Codable, Equatable {
    case unknown // = 0
    case predeliveryOwner // = 1
    case primaryOwner // = 2
    case secondaryOwner // = 3
    case deliveryTeam // = 4
    case serviceTeam // = 5
    case customerSupportTeam // = 6
    case readOnly // = 7
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_AccessLevel) {
        switch proto {
        case .unknown: self = .unknown
        case .predeliveryOwner: self = .predeliveryOwner
        case .primaryOwner: self = .primaryOwner
        case .secondaryOwner: self = .secondaryOwner
        case .deliveryTeam: self = .deliveryTeam
        case .serviceTeam: self = .serviceTeam
        case .customerSupportTeam: self = .customerSupportTeam
        case .readOnly: self = .readOnly
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
