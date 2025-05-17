//
//  BatteryState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

enum WarningState: Codable, Equatable {
    case warningUnknown // = 0
    case warningOff // = 1
    case warningOn // = 2
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .warningUnknown: return 0
        case .warningOff: return 1
        case .warningOn: return 2
        case .UNRECOGNIZED(let i): return i
        }
    }
    
    init(proto: Mobilegateway_Protos_WarningState) {
        switch proto {
        case .warningUnknown:
                self = .warningUnknown
        case .warningOff:
            self = .warningOff
        case .warningOn:
            self = .warningOn
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum PreconditioningStatus: Codable, Equatable {
    case batteryPreconUnknown // = 0
    case batteryPreconOff // = 1
    case batteryPreconOn // = 2
    case batteryPreconUnavailable // = 3
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .batteryPreconUnknown: return 0
        case .batteryPreconOff: return 1
        case .batteryPreconOn: return 2
        case .batteryPreconUnavailable: return 3
        case .UNRECOGNIZED(let int): return int
        }
    }
    
    init(proto: Mobilegateway_Protos_BatteryPreconStatus) {
        switch proto {
        case .batteryPreconUnknown:
            self = .batteryPreconUnknown
        case .batteryPreconOff:
            self = .batteryPreconOff
        case .batteryPreconOn:
            self = .batteryPreconOn
        case .batteryPreconUnavailable:
            self = .batteryPreconUnavailable
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum BatteryCellType: Codable, Equatable {
    case unknown // = 0
    case lgM48 // = 1
    case sdi50G // = 2
    case pana2170M // = 3
    case sdi50Gv2 // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_BatteryCellType) {
        switch proto {
        case .unknown:
            self = .unknown
        case .lgM48:
            self = .lgM48
        case .sdi50G:
            self = .sdi50G
        case .pana2170M:
            self = .pana2170M
        case .sdi50Gv2:
            self = .sdi50Gv2
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum BatteryPackType: Codable, Equatable {
    case unknown // = 0
    case air22 // = 1
    case air18 // = 2
    case air16 // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_BatteryPackType) {
        switch proto {
        case .unknown:
            self = .unknown
        case .air22:
            self = .air22
        case .air18:
            self = .air18
        case .air16:
            self = .air16
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

struct BatteryState: Codable, Equatable {
    let remainingRange: Double
    let chargePercent: Double
    let kwHr: Double
    let capacityKwHr: Double
    let batteryHealth: WarningState
    let lowChargeLevel: WarningState
    let criticalChargeLevel: WarningState
    let unavailableRange: Double
    let preconditioningStatus: PreconditioningStatus
    let preconditioningTimeRemaining: UInt32
    let batteryHealthLevel: Double
    let bmuSoftwareVersionMajor: UInt32
    let bmuSoftwareVersionMinor: UInt32
    let bmuSoftwareVersionMicro: UInt32
    let batteryCellType: BatteryCellType
    let batteryPackType: BatteryPackType
    let maxCellTemp: Double
    let minCellTemp: Double
    
    init(proto: Mobilegateway_Protos_BatteryState) {
        self.remainingRange = proto.remainingRange
        self.chargePercent = proto.chargePercent
        self.kwHr = proto.kwhr
        self.capacityKwHr = proto.capacityKwhr
        self.batteryHealth = WarningState(proto: proto.batteryHealth)
        self.lowChargeLevel = WarningState(proto: proto.lowChargeLevel)
        self.criticalChargeLevel = WarningState(proto: proto.criticalChargeLevel)
        self.unavailableRange = proto.unavailableRange
        self.preconditioningStatus = PreconditioningStatus(proto: proto.preconditioningStatus)
        self.preconditioningTimeRemaining = proto.preconditioningTimeRemaining
        self.batteryHealthLevel = proto.batteryHealthLevel
        self.bmuSoftwareVersionMajor = proto.bmuSoftwareVersionMajor
        self.bmuSoftwareVersionMinor = proto.bmuSoftwareVersionMinor
        self.bmuSoftwareVersionMicro = proto.bmuSoftwareVersionMicro
        self.batteryCellType = BatteryCellType(proto: proto.batteryCellType)
        self.batteryPackType = BatteryPackType(proto: proto.batteryPackType)
        self.maxCellTemp = proto.maxCellTemp
        self.minCellTemp = proto.minCellTemp
    }
}
