//
//  VehicleState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleState: Codable, Equatable {
    let batteryState: BatteryState
    let powerState: PowerState
    let cabinState: CabinState
    var bodyState: BodyState
    let lastUpdatedMs: String
    var chassisState: ChassisState
    let chargingState: ChargingState
    let gps: GPS
    let softwareUpdate: SoftwareUpdate
    let alarmState: AlarmState
    let cloudConnectionState: CloudConnection
    let keylessDrivingState: KeylessDrivingState
    var hvacState: HVACState
    let driveMode: DriveMode
    let privacyMode: PrivacyMode
    let gearPosition: GearPosition
    let mobileAppReqStatus: MobileAppReqStatus
    let tcuState: TcuState
    let tcuInternetStatus: TCUInternetStatus
}

enum KeylessDrivingState: Codable, Equatable {
    case keylessDrivingUnknown // = 0
    case keylessDrivingOn // = 1
    case keylessDrivingOff // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_KeylessDrivingState) {
        switch proto {
        case .keylessDrivingUnknown: self = .keylessDrivingUnknown
        case .keylessDrivingOn: self = .keylessDrivingOn
        case .keylessDrivingOff: self = .keylessDrivingOff
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum CloudConnection: Codable, Equatable {
    case cloudConnectionUnknown // = 0
    case cloudConnectionConnected // = 1
    case cloudConnectionDisconnected // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_CloudConnectionState) {
        switch proto {
        case .cloudConnectionUnknown: self = .cloudConnectionUnknown
        case .cloudConnectionConnected: self = .cloudConnectionConnected
        case .cloudConnectionDisconnected: self = .cloudConnectionDisconnected
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum PowerState: Codable, Equatable {
    case unknown // = 0
    case sleep // = 1
    case wink // = 2
    case accessory // = 3
    case drive // = 4
    case liveCharge // = 5
    case sleepCharge // = 6
    case liveUpdate // = 7
    case sleepUpdate // = 8
    case cloud1 // = 9
    case cloud2 // = 10
    case monitor // = 11
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PowerState) {
        switch proto {
        case .unknown: self = .unknown
        case .sleep: self = .sleep
        case .wink: self = .wink
        case .accessory: self = .accessory
        case .drive: self = .drive
        case .liveCharge: self = .liveCharge
        case .sleepCharge: self = .sleepCharge
        case .liveUpdate: self = .liveUpdate
        case .sleepUpdate: self = .sleepUpdate
        case .cloud1: self = .cloud1
        case .cloud2: self = .cloud2
        case .monitor: self = .monitor
        case .UNRECOGNIZED(let value): self = .UNRECOGNIZED(value)
        }
    }
    
    var image: String {
        switch self {
        case .unknown:
            "questionmark"
        case .sleep, .wink, .cloud1, .cloud2:
            "zzz"
        case .liveCharge:
            "bolt.fill"
        case .sleepCharge:
            "bolt"
        case .monitor, .accessory:
            "parkingsign"
        case .liveUpdate:
            "car.rear.waves.up"
        case .sleepUpdate:
            "car.rear.waves.up"
        case .drive:
            "car.rear.road.lane.dashed"
        case .UNRECOGNIZED(_):
            ""
        }
    }
}
