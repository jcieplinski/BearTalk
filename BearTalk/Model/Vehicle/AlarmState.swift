//
//  AlarmState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct AlarmState: Codable, Equatable {
    let alarmStatus: AlarmStatus
    let alarmMode: AlarmMode
    
    init(proto: Mobilegateway_Protos_AlarmState) {
        alarmStatus = .init(proto: proto.status)
        alarmMode = .init(proto: proto.mode)
    }
}

enum AlarmMode: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case silent // = 3
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown: return 0
        case .off: return 1
        case .on: return 2
        case .silent: return 3
        case .UNRECOGNIZED(let int): return int
        }
    }
    
    init(proto: Mobilegateway_Protos_AlarmMode) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .silent: self = .silent
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum AlarmStatus: Codable, Equatable {
    case unknown // = 0
    case disarmed // = 1
    case armed // = 2
    case preAlarm // = 3
    case tilt // = 4
    case shock // = 5
    case intrusion // = 6
    case panicMode // = 7
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_AlarmStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .disarmed: self = .disarmed
        case .armed: self = .armed
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        case .preAlarm: self = .preAlarm
        case .tilt: self = .tilt
        case .shock: self = .shock
        case .intrusion: self = .intrusion
        case .panicMode: self = .panicMode
        }
    }
}
