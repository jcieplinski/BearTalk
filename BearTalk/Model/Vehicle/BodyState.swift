//
//  BodyState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct BodyState: Codable, Equatable {
    var doorLocks: LockState
    var frontCargo: DoorState
    var rearCargo: DoorState
    let frontLeftDoor: DoorState
    let frontRightDoor: DoorState
    let rearLeftDoor: DoorState
    let rearRightDoor: DoorState
    var chargePortState: DoorState
    let walkawayLockSts: WalkawayState
    let accessTypeSts: AccessRequest
    
    internal init(proto: Mobilegateway_Protos_BodyState) {
        self.doorLocks = LockState(proto: proto.doorLocks)
        self.frontCargo = DoorState(proto: proto.frontCargo)
        self.rearCargo = DoorState(proto: proto.rearCargo)
        self.frontLeftDoor = DoorState(proto: proto.frontLeftDoor)
        self.frontRightDoor = DoorState(proto: proto.frontRightDoor)
        self.rearLeftDoor = DoorState(proto: proto.rearLeftDoor)
        self.rearRightDoor = DoorState(proto: proto.rearRightDoor)
        self.chargePortState = DoorState(proto: proto.chargePort)
        self.walkawayLockSts = WalkawayState(proto: proto.walkawayLock)
        self.accessTypeSts = AccessRequest(proto: proto.accessTypeStatus)
    }
}


enum DoorState: Codable, Equatable {
    case unknown // = 0
    case `open` // = 1
    case closed // = 2
    case ajar // = 3
    case closeError // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_DoorState) {
        switch proto {
        case .unknown:
            self = .unknown
        case .open:
            self = .open
        case .closed:
            self = .closed
        case .ajar:
            self = .ajar
        case .closeError:
            self = .closeError
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
    
    var intValue: Int {
        switch self {
        case .unknown: 0
        case .open: 1
        case .closed: 2
        case .ajar: 3
        case .closeError: 4
        case .UNRECOGNIZED(let int): int
        }
    }
    
    var frunkImage: String {
        switch self {
        case .open, .ajar:
            return "frunkOpen"
        case .closed:
            return "frunkClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "frunkClosed"
        }
    }
    
    var trunkImage: String {
        switch self {
        case .open, .ajar:
            return "trunkOpen"
        case .closed:
            return "trunkClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "trunkClosed"
        }
    }
    
    var chargePortImage: String {
        switch self {
        case .open, .ajar:
            return "chargePortOpen"
        case .closed:
            return "chargePortClosed"
        case .unknown, .UNRECOGNIZED(_), .closeError:
            return "chargePortClosed"
            
        }
    }
}

enum WalkawayState: Codable, Equatable {
    case walkawayUnknown // = 0
    case walkawayIdle // = 1
    case walkawayActive // = 2
    case walkawayDisable // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_WalkawayState) {
        switch proto {
        case .walkawayUnknown:
            self = .walkawayUnknown
        case .walkawayActive:
            self = .walkawayActive
        case .walkawayIdle:
            self = .walkawayIdle
        case .walkawayDisable:
            self = .walkawayDisable
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum AccessRequest: Codable, Equatable {
    case unknown // = 0
    case active // = 1
    case passive // = 2
    case passiveDriver // = 3
    case passiveTempDisabled // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_AccessRequest) {
        switch proto {
        case .unknown:
            self = .unknown
        case .active:
            self = .active
        case .passive:
            self = .passive
        case .passiveDriver:
            self = .passiveDriver
        case .passiveTempDisabled:
            self = .passiveTempDisabled
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}
