//
//  ChargingState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct ChargingState: Codable, Equatable {
    let chargeState: ChargeState
    let energyType: EnergyType
    let chargeSessionMi: Double
    let chargeSessionKwh: Double
    let sessionMinutesRemaining: UInt32
    let chargeLimit: UInt32
    let cableLock: LockState
    let chargeRateKwhPrecise: Double
    let chargeRateMphPrecise: Double
    let chargeRateMilesMinPrecise: Double
    let chargeLimitPercent: Double
    let chargeScheduledStatus: String
    let chargeScheduledTime: UInt32
    let scheduledCharge: ScheduledChargeState
    let scheduledChargeUnavailable: ScheduledChargeUnavailableState
    let portPower: Double
    let acOutletUnavailableReason: AcOutletUnavailableReason
    let dischargeCommand: MobileDischargingCommand
    let dischargeSoeLimit: UInt32
    let dischargeTargetSoe: UInt32
    let dischargeEnergy: Double
    let activeSessionAcCurrentLimit: UInt32
    let energyAcCurrentLimit: UInt32
    let eaPncStatus: EaPncStatus
    let chargingSessionRestartAllowed: ChargingSessionRestartAllowed
    
    init(proto: Mobilegateway_Protos_ChargingState) {
        self.chargeState = .init(proto: proto.chargeState)
        self.energyType = .init(proto: proto.energyType)
        self.chargeSessionMi = proto.chargeSessionMi
        self.chargeSessionKwh = proto.chargeSessionKwh
        self.sessionMinutesRemaining = proto.sessionMinutesRemaining
        self.chargeLimit = proto.chargeLimit
        self.cableLock = .init(proto: proto.cableLock)
        self.chargeRateKwhPrecise = proto.chargeRateKwhPrecise
        self.chargeRateMphPrecise = proto.chargeRateMphPrecise
        self.chargeRateMilesMinPrecise = proto.chargeRateMilesMinPrecise
        self.chargeLimitPercent = proto.chargeLimitPercent
        self.chargeScheduledStatus = proto.chargeScheduledTime == 0 ? "not scheduled" : "scheduled"
        self.chargeScheduledTime = proto.chargeScheduledTime
        self.scheduledCharge = .init(proto: proto.scheduledCharge)
        self.scheduledChargeUnavailable = .init(proto: proto.scheduledChargeUnavailable)
        self.portPower = proto.portPower
        self.acOutletUnavailableReason = .init(proto: proto.acOutletUnavailableReason)
        self.dischargeCommand = .init(proto: proto.dischargeCommand)
        self.dischargeSoeLimit = proto.dischargeSoeLimit
        self.dischargeTargetSoe = proto.dischargeTargetSoe
        self.dischargeEnergy = proto.dischargeEnergy
        self.activeSessionAcCurrentLimit = proto.activeSessionAcCurrentLimit
        self.energyAcCurrentLimit = proto.energyAcCurrentLimit
        self.eaPncStatus = .init(proto: proto.eaPncStatus)
        self.chargingSessionRestartAllowed = .init(proto: proto.chargingSessionRestartAllowed)
    }
}

enum ChargingSessionRestartAllowed: Codable, Equatable {
    case statusUnknown // = 0
    case statusIdle // = 1
    case statusNotAllowed // = 2
    case statusAllowed // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_ChargingSessionRestartAllowed) {
        switch proto {
        case .statusUnknown: self = .statusUnknown
        case .statusIdle: self = .statusIdle
        case .statusNotAllowed: self = .statusNotAllowed
        case .statusAllowed: self = .statusAllowed
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum EaPncStatus: Codable, Equatable {
    case unknown // = 0
    case idle // = 1
    case enable // = 2
    case disable // = 3
    case noNotification // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_EaPncStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .idle: self = .idle
        case .enable: self = .enable
        case .disable: self = .disable
        case .noNotification: self = .noNotification
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum MobileDischargingCommand: Codable, Equatable {
    case unknown // = 0
    case startDischarging // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_MobileDischargingCommand) {
        switch proto {
        case .unknown: self = .unknown
        case .startDischarging: self = .startDischarging
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum AcOutletUnavailableReason: Codable, Equatable {
    case unknown // = 0
    case none // = 1
    case warningFault // = 2
    case criticalFault // = 3
    case charging // = 4
    case lowVehRange // = 5
    case warningFaultCamp // = 6
    case criticalFaultCamp // = 7
    case lowVehRangeCamp // = 8
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_AcOutletUnavailableReason) {
        switch proto {
        case .unknown: self = .unknown
        case .none: self = .none
        case .warningFault: self = .warningFault
        case .criticalFault: self = .criticalFault
        case .charging: self = .charging
        case .lowVehRange: self = .lowVehRange
        case .warningFaultCamp: self = .warningFaultCamp
        case .criticalFaultCamp: self = .criticalFaultCamp
        case .lowVehRangeCamp: self = .lowVehRangeCamp
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum ChargeState: Codable, Equatable {
    case unknown // = 0
    case notConnected // = 1
    case cableConnected // = 2
    case establishingSession // = 3
    case authorizingPnc // = 4
    case authorizingExternal // = 5
    case authorized // = 6
    case chargerPreparation // = 7
    case charging // = 8
    case chargingEndOk // = 9
    case chargingEndError // = 10
    case evseMalfunction // = 11
    case authenticationFailure // = 12
    case chargingStopped // = 13
    case chargingPaused // = 14
    case authenticationPncFailure // = 15
    case internalHardwareFault // = 16
    case readyToDischarge // = 17
    case preparingDischarge // = 18
    case discharging // = 19
    case dischargingCompleted // = 20
    case dischargingStopped // = 21
    case dischargingFault // = 22
    case dischargingUnavailable // = 23
    case evseNotReady // = 25
    case acInputUnderVoltage // = 26
    case cableLockFault // = 27
    case cableConnectionFault // = 28
    case tempProtection // = 29
    case chargingScheduled // = 30
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_ChargeState) {
        switch proto {
        case .unknown: self = .unknown
        case .notConnected: self = .notConnected
        case .cableConnected: self = .cableConnected
        case .establishingSession: self = .establishingSession
        case .authorizingPnc: self = .authorizingPnc
        case .authorizingExternal: self = .authorizingExternal
        case .authorized: self = .authorized
        case .chargerPreparation: self = .chargerPreparation
        case .charging: self = .charging
        case .chargingEndOk: self = .chargingEndOk
        case .chargingStopped: self = .chargingStopped
        case .evseMalfunction: self = .evseMalfunction
        case .discharging: self = .discharging
        case .dischargingCompleted: self = .dischargingCompleted
        case .dischargingStopped: self = .dischargingStopped
        case .dischargingFault: self = .dischargingFault
        case .dischargingUnavailable: self = .dischargingUnavailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        case .chargingEndError: self = .chargingEndError
        case .authenticationFailure: self = .authenticationFailure
        case .chargingPaused: self = .chargingPaused
        case .authenticationPncFailure: self = .authenticationPncFailure
        case .internalHardwareFault: self = .internalHardwareFault
        case .readyToDischarge: self = .readyToDischarge
        case .preparingDischarge: self = .preparingDischarge
        case .evseNotReady: self = .evseNotReady
        case .acInputUnderVoltage: self = .acInputUnderVoltage
        case .cableLockFault: self = .cableLockFault
        case .cableConnectionFault: self = .cableConnectionFault
        case .tempProtection: self = .tempProtection
        case .chargingScheduled: self = .chargingScheduled
        }
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .charging:
            "Charging in Progress"
        case .notConnected:
            "Not Connected"
        case .cableConnected:
            "Cable Connected"
        case .establishingSession:
            "Establishing Session"
        case .authorizingPnc:
            "Authorizing PNC"
        case .authorizingExternal:
            "Authorizing External"
        case .authorized:
            "Authorized"
        case .chargerPreparation:
            "Preparing to Charge"
        case .chargingEndOk:
            "Charging Complete"
        case .chargingStopped:
            "Charging Stopped"
        case .evseMalfunction:
            "Charging Error"
        case .discharging:
            "Discharging"
        case .dischargingCompleted:
            "Discharging Complete"
        case .dischargingStopped:
            "Discharging Stopped"
        case .dischargingFault:
            "Discharging Error"
        case .dischargingUnavailable:
            "Discharging Unavailable"
        case .unknown, .UNRECOGNIZED:
            "Unknown Status"
        case .evseNotReady:
            "EVSE Not Ready"
        case .chargingEndError:
            "Charging End Error"
        case .authenticationFailure:
            "Authentication Failure"
        case .chargingPaused:
            "Charging Paused"
        case .authenticationPncFailure:
            "Authentication PnC Failure"
        case .internalHardwareFault:
            "Internal Hardware Fault"
        case .readyToDischarge:
            "Ready to Discharge"
        case .preparingDischarge:
            "Preparing Discharge"
        case .acInputUnderVoltage:
            "AC Input Under Voltage"
        case .cableLockFault:
            "Cable Lock Fault"
        case .cableConnectionFault:
            "Cable Connection Fault"
        case .tempProtection:
            "Temp Protection"
        case .chargingScheduled:
            "Charging Scheuled"
        }
    }
}

enum EnergyType: Codable, Equatable {
    case unknown // = 0
    case ac // = 1
    case dc // = 2
    case digital // = 3
    case v2V // = 4
    case none // = 5
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_EnergyType) {
        switch proto {
        case .unknown: self = .unknown
        case .ac: self = .ac
        case .dc: self = .dc
        case .digital: self = .digital
        case .v2V: self = .v2V
        case .none: self = .none
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum ScheduledChargeState: Codable, Equatable {
    case unknown // = 0
    case idle // = 1
    case scheduledToCharge // = 2
    case requestToCharge // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_ScheduledChargeState) {
        switch proto {
        case .unknown: self = .unknown
        case .idle: self = .idle
        case .scheduledToCharge: self = .scheduledToCharge
        case .requestToCharge: self = .requestToCharge
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum ScheduledChargeUnavailableState: Codable, Equatable {
    case scheduledChargeUnavailableUnknown // = 0
    case scheduledChargeUnavailableNoRequest // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_ScheduledChargeUnavailableState) {
        switch proto {
        case .scheduledChargeUnavailableUnknown: self = .scheduledChargeUnavailableUnknown
        case .scheduledChargeUnavailableNoRequest: self = .scheduledChargeUnavailableNoRequest
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
