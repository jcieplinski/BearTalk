//
//  ChassisState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct ChassisState: Codable, Equatable {
    let odometerKm: Double
    let frontLeftTirePressureBar: Double
    let frontRightTirePressureBar: Double
    let rearLeftTirePressureBar: Double
    let rearRightTirePressureBar: Double
    var headlights: LightState
    let hardWarnLeftFront: WarningState
    let hardWarnLeftRear: WarningState
    let hardWarnRightFront: WarningState
    let hardWarnRightRear: WarningState
    let softWarnLeftFront: WarningState
    let softWarnLeftRear: WarningState
    let softWarnRightFront: WarningState
    let softWarnRightRear: WarningState
    let softwareVersion: String
    
    let speed: Double
    let sensorDefectiveLeftFront: TirePressureSensorDefective
    let sensorDefectiveLeftRear: TirePressureSensorDefective
    let sensorDefectiveRightFront: TirePressureSensorDefective
    let sensorDefectiveRightRear: TirePressureSensorDefective
    let tirePressureLastUpdated: UInt64
    
    init(proto: Mobilegateway_Protos_ChassisState) {
        self.odometerKm = Double(proto.odometerKm)
        self.frontLeftTirePressureBar = Double(proto.frontLeftTirePressureBar)
        self.frontRightTirePressureBar = Double(proto.frontRightTirePressureBar)
        self.rearLeftTirePressureBar = Double(proto.rearLeftTirePressureBar)
        self.rearRightTirePressureBar = Double(proto.rearRightTirePressureBar)
        self.headlights = .init(proto: proto.headlights)
        self.hardWarnLeftFront = .init(proto: proto.hardWarnLeftFront)
        self.hardWarnLeftRear = .init(proto: proto.hardWarnLeftRear)
        self.hardWarnRightFront = .init(proto: proto.hardWarnRightFront)
        self.hardWarnRightRear = .init(proto: proto.hardWarnRightRear)
        self.softWarnLeftFront = .init(proto: proto.softWarnLeftFront)
        self.softWarnLeftRear = .init(proto: proto.softWarnLeftRear)
        self.softWarnRightFront = .init(proto: proto.softWarnRightFront)
        self.softWarnRightRear = .init(proto: proto.softWarnRightRear)
        self.softwareVersion = String(proto.softwareVersion)
        
        self.speed = proto.speed
        self.sensorDefectiveLeftRear = .init(proto: proto.sensorDefectiveLeftRear)
        self.sensorDefectiveLeftFront = .init(proto: proto.sensorDefectiveLeftFront)
        self.sensorDefectiveRightRear = .init(proto: proto.sensorDefectiveRightRear)
        self.sensorDefectiveRightFront = .init(proto: proto.sensorDefectiveRightFront)
        self.tirePressureLastUpdated = proto.tirePressureLastUpdated
    }
}

enum LightState: Codable, Equatable {
    case unknown // = 0
    case flash // = 1
    case on // = 2
    case off // = 3
    case hazardOn // = 4
    case hazardOff // = 5
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown: return 0
        case .flash: return 1
        case .on: return 2
        case .off: return 3
        case .hazardOn: return 4
        case .hazardOff: return 5
        case .UNRECOGNIZED(let int): return int
        }
    }
    
    init(proto: Mobilegateway_Protos_LightAction) {
        switch proto {
        case .off:
            self = .off
        case .on:
            self = .on
        case .unknown:
            self = .unknown
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        case .flash:
            self = .flash
        case .hazardOn:
            self = .hazardOn
        case .hazardOff:
            self = .hazardOff
        }
    }
}

enum TirePressureSensorDefective: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_TirePressureSensorDefective) {
        switch proto {
        case .unknown:
            self = .unknown
        case .off:
            self = .off
        case .on:
            self = .on
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}
