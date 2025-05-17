//
//  HVACStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

enum DefrostState: Codable, Equatable {
    case unknown // = 0
    case defrostOn // = 1
    case defrostOff // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_DefrostState) {
        switch proto {
        case .unknown: self = .unknown
        case .defrostOn: self = .defrostOn
        case .defrostOff: self = .defrostOff
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
    
    var intvalue: Int {
        switch self {
        case .unknown: return 0
        case .defrostOn: return 1
        case .defrostOff: return 2
        case .UNRECOGNIZED(let int): return int
        }
    }
    
    var defrostImage: String {
        switch self {
        case .defrostOn:
            return "defrostOn"
        case .defrostOff:
            return "defrostOff"
        case .unknown, .UNRECOGNIZED(_):
            return "questionmark"
        }
    }
}

enum HvacPower: Codable, Equatable {
    case unknown // = 0
    case hvacOn // = 1
    case hvacOff // = 2
    case hvacPrecondition // = 3
    case hvacKeepTemp // = 6
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_HvacPower) {
        switch proto {
        case .unknown: self = .unknown
        case .hvacOn: self = .hvacOn
        case .hvacOff: self = .hvacOff
        case .hvacPrecondition: self = .hvacPrecondition
        case .hvacKeepTemp: self = .hvacKeepTemp
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum LightAction: Codable, Equatable {
    case unknown // = 0
    case flash // = 1
    case on // = 2
    case off // = 3
    case hazardOn // = 4
    case hazardOff // = 5
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_LightAction) {
        switch proto {
        case .unknown: self = .unknown
        case .flash: self = .flash
        case .on: self = .on
        case .off: self = .off
        case .hazardOn: self = .hazardOn
        case .hazardOff: self = .hazardOff
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
    
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
    
    var lightsImage: String {
        switch self {
        case .on:
            return "lightsOn"
        case .off:
            return "lightsOff"
        case .flash:
            return "flashLightsOff"
        case .unknown, .UNRECOGNIZED(_):
            return "questionmark"
        case .hazardOn:
            return "questionmark"
        case .hazardOff:
            return "questionmark"
        }
    }
}

enum PanicState: Codable, Equatable {
    case panicAlarmUnknown // = 0
    case panicAlarmOn // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PanicState) {
        switch proto {
        case .panicAlarmUnknown: self = .panicAlarmUnknown
        case .panicAlarmOn: self = .panicAlarmOn
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SharedTripState: Codable, Equatable {
    case sharedTripUnknown // = 0
    case sharedTripAvailable // = 1
    case sharedTripProfileUpdated // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SharedTripState) {
        switch proto {
        case .sharedTripUnknown: self = .sharedTripUnknown
        case .sharedTripAvailable: self = .sharedTripAvailable
        case .sharedTripProfileUpdated: self = .sharedTripProfileUpdated
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct MobileAppReqState: Codable, Equatable {
    let alarmSetRequest: AlarmMode
    let chargePortRequest: DoorState
    let frunkCargoRequest: DoorState
    let hornRequest: DoorState
    let hvacDefrost: DefrostState
    let hvacPrecondition: HvacPower
    let lightRequest: LightAction
    let panicRequest: PanicState
    let sharedTripRequest: SharedTripState
    let trunkCargoRequest: DoorState
    let vehicleUnlockRequest: LockState
    
    init(proto: Mobilegateway_Protos_MobileAppReqState) {
        alarmSetRequest = .init(proto: proto.alarmSetRequest)
        chargePortRequest = .init(proto: proto.chargePortRequest)
        frunkCargoRequest = .init(proto: proto.frunkCargoRequest)
        hornRequest = .init(proto: proto.hornRequest)
        hvacDefrost = .init(proto: proto.hvacDefrost)
        hvacPrecondition = .init(proto: proto.hvacPrecondition)
        lightRequest = .init(proto: proto.lightRequest)
        panicRequest = .init(proto: proto.panicRequest)
        sharedTripRequest = .init(proto: proto.sharedTripRequest)
        trunkCargoRequest = .init(proto: proto.trunkCargoRequest)
        vehicleUnlockRequest = .init(proto: proto.vehicleUnlockRequest)
    }
}

enum TcuState: Codable, Equatable {
    case tcuUnknown // = 0
    case tcuSleep // = 1
    case tcuDrowsy // = 2
    case tcuFull // = 4
    
    /// State during an update
    case tcuFactory // = 5
    case tcuPower // = 6
    case tcuOff // = 7
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_TcuState) {
        switch proto {
        case .tcuUnknown: self = .tcuUnknown
        case .tcuSleep: self = .tcuSleep
        case .tcuDrowsy: self = .tcuDrowsy
        case .tcuFull: self = .tcuFull
        case .tcuFactory: self = .tcuFactory
        case .tcuPower: self = .tcuPower
        case .tcuOff: self = .tcuOff
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum EnablementState: Codable, Equatable {
    case unknown // = 0
    case idle // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_EnablementState) {
        switch proto {
        case .unknown: self = .unknown
        case .idle: self = .idle
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SentSentryThreat: Codable, Equatable {
    case levelUnknown // = 0
    case idle // = 1
    case levelOne // = 2
    case levelTwo // = 3
    case levelThree // = 4
    case noThreat // = 5
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SentryThreat) {
        switch proto {
        case .levelUnknown: self = .levelUnknown
        case .idle: self = .idle
        case .levelOne: self = .levelOne
        case .levelTwo: self = .levelTwo
        case .levelThree: self = .levelThree
        case .noThreat: self = .noThreat
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct MultiplexValues: Codable, Equatable {
    
}

enum SentryUsbDriveStatus: Codable, Equatable {
    case unknownSentryUsbDriveStatus // = 0
    case sentryUsbDriveIdle // = 1
    case sentryUsbDriveConnected // = 2
    case sentryUsbDriveNotConnected // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SentryUsbDriveStatus) {
        switch proto {
        case .unknownSentryUsbDriveStatus: self = .unknownSentryUsbDriveStatus
        case .sentryUsbDriveIdle: self = .sentryUsbDriveIdle
        case .sentryUsbDriveConnected: self = .sentryUsbDriveConnected
        case .sentryUsbDriveNotConnected: self = .sentryUsbDriveNotConnected
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum EnhancedDeterrenceState: Codable, Equatable {
    case unknown // = 0
    case enhancedDeterrenceEnabled // = 1
    case enhancedDeterrenceDisabled // = 2
    case enhancedDeterrenceIdle // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_EnhancedDeterrenceState) {
        switch proto {
        case .unknown: self = .unknown
        case .enhancedDeterrenceEnabled: self = .enhancedDeterrenceEnabled
        case .enhancedDeterrenceDisabled: self = .enhancedDeterrenceDisabled
        case .enhancedDeterrenceIdle: self = .enhancedDeterrenceIdle
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SentryRemoteAlarmState: Codable, Equatable {
    case unknown // = 0
    case sentryRemoteAlarmIdle // = 1
    case sentryRemoteAlarmOn // = 2
    case sentryRemoteAlarmOff // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SentryRemoteAlarmState) {
        switch proto {
        case .unknown: self = .unknown
        case .sentryRemoteAlarmIdle: self = .sentryRemoteAlarmIdle
        case .sentryRemoteAlarmOn: self = .sentryRemoteAlarmOn
        case .sentryRemoteAlarmOff: self = .sentryRemoteAlarmOff
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct SentryState: Codable, Equatable {
    let enablementState: EnablementState
    let threatLevel: SentSentryThreat
    let multiplexValues: MultiplexValues
    let usbDriveStatus: SentryUsbDriveStatus
    let enhancedDeterrenceState: EnhancedDeterrenceState
    let rangeCostPerDay: UInt32
    let remoteAlarmState: SentryRemoteAlarmState
}

enum MpbFaultStatus: Codable, Equatable {
    case unknown // = 0
    case normal // = 1
    case critical // = 3
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_MpbFaultStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .normal: self = .normal
        case .critical: self = .critical
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct FaultState: Codable, Equatable {
    public var mpbFaultStatus: MpbFaultStatus
    
    init(proto: Mobilegateway_Protos_FaultState) {
        mpbFaultStatus = .init(proto: proto.mpbFaultStatus)
    }
}

enum PowertrainMessage: Codable, Equatable {
    case unknown // = 0
    case blankNoMessage // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PowertrainMessage) {
        switch proto {
        case .unknown: self = .unknown
        case .blankNoMessage: self = .blankNoMessage
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum PowertrainNotifyStatus: Codable, Equatable {
    case powertrainNotifyUnknown // = 0
    case powertrainNotifyNone // = 1
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PowertrainNotifyStatus) {
        switch proto {
        case .powertrainNotifyUnknown: self = .powertrainNotifyUnknown
        case .powertrainNotifyNone: self = .powertrainNotifyNone
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum GeneralChargeStatus: Codable, Equatable {
    case generalChargeUnknown // = 0
    case generalChargeDefault // = 1
    case generalChargeDeratedChargingPower // = 4
    case generalChargeSavetimeTempPrecon // = 5
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_GeneralChargeStatus) {
        switch proto {
        case .generalChargeUnknown: self = .generalChargeUnknown
        case .generalChargeDefault: self = .generalChargeDefault
        case .generalChargeDeratedChargingPower: self = .generalChargeDeratedChargingPower
        case .generalChargeSavetimeTempPrecon: self = .generalChargeSavetimeTempPrecon
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
    
struct HvacNotifications: Codable, Equatable {
    let powertrainMessage: PowertrainMessage
    let powertrainNotifyStatus: PowertrainNotifyStatus
    let chargingGeneralStatus: GeneralChargeStatus
    let batteryChargeStatus: GeneralChargeStatus
    
    init(proto: Mobilegateway_Protos_Notifications) {
        self.powertrainMessage = .init(proto: proto.powertrainMessage)
        self.powertrainNotifyStatus = .init(proto: proto.powertrainNotifyStatus)
        self.chargingGeneralStatus = .init(proto: proto.chargingGeneralStatus)
        self.batteryChargeStatus = .init(proto: proto.batteryChargeStatus)
    }
}

enum LowPowerModeStatus: Codable, Equatable {
    case unknown // = 0
    case inactive // = 1
    case active // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_LowPowerModeStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .inactive: self = .inactive
        case .active: self = .active
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum HvacPreconditionStatus: Codable, Equatable {
    case unknown // = 0
    case stillActive // = 1
    case tempReached // = 2
    case timeout // = 3
    case userInput // = 4
    case notActivePrecondition // = 6
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_HvacPreconditionStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .stillActive: self = .stillActive
        case .tempReached: self = .tempReached
        case .timeout: self = .timeout
        case .userInput: self = .userInput
        case .notActivePrecondition: self = .notActivePrecondition
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum KeepClimateStatus: Codable, Equatable {
    case unknown // = 0
    case inactive // = 1
    case enabled // = 2
    case canceled // = 3
    case petModeOn // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_KeepClimateStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .inactive: self = .inactive
        case .enabled: self = .enabled
        case .canceled: self = .canceled
        case .petModeOn: self = .petModeOn
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum MaxACState: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown:
            0
        case .off:
            1
        case .on:
            2
        case .UNRECOGNIZED(let int):
            int
        }
    }
    
    init(proto: Mobilegateway_Protos_MaxACState) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SeatClimateMode: Codable, Equatable {
    case unknown // = 0
    case off // = 2
    case low // = 3
    case medium // = 4
    case high // = 5
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown:
            0
        case .off:
            2
        case .low:
            3
        case .medium:
            4
        case .high:
            5
        case .UNRECOGNIZED(let int):
            int
        }
    }
    
    init(proto: Mobilegateway_Protos_SeatClimateMode) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .low: self = .low
        case .medium: self = .medium
        case .high: self = .high
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct SeatClimateState: Codable, Equatable {
    let driverHeatBackrestZone1: SeatClimateMode
    let driverHeatBackrestZone3: SeatClimateMode
    let driverHeatCushionZone2: SeatClimateMode
    let driverHeatCushionZone4: SeatClimateMode
    let driverVentBackrest: SeatClimateMode
    let driverVentCushion: SeatClimateMode
    let frontPassengerHeatBackrestZone1: SeatClimateMode
    let frontPassengerHeatBackrestZone3: SeatClimateMode
    let frontPassengerHeatCushionZone2: SeatClimateMode
    let frontPassengerHeatCushionZone4: SeatClimateMode
    let frontPassengerVentBackrest: SeatClimateMode
    let frontPassengerVentCushion: SeatClimateMode
    let rearPassengerHeatLeft: SeatClimateMode
    let rearPassengerHeatCenter: SeatClimateMode
    let rearPassengerHeatRight: SeatClimateMode
    
    init(proto: Mobilegateway_Protos_SeatClimateState) {
        driverHeatBackrestZone1 = .init(proto: proto.driverHeatBackrestZone1)
        driverHeatBackrestZone3 = .init(proto: proto.driverHeatBackrestZone3)
        driverHeatCushionZone2 = .init(proto: proto.driverHeatCushionZone2)
        driverHeatCushionZone4 = .init(proto: proto.driverHeatCushionZone4)
        driverVentBackrest = .init(proto: proto.driverVentBackrest)
        driverVentCushion = .init(proto: proto.driverVentCushion)
        frontPassengerHeatBackrestZone1 = .init(proto: proto.frontPassengerHeatBackrestZone1)
        frontPassengerHeatBackrestZone3 = .init(proto: proto.frontPassengerHeatBackrestZone3)
        frontPassengerHeatCushionZone2 = .init(proto: proto.frontPassengerHeatCushionZone2)
        frontPassengerHeatCushionZone4 = .init(proto: proto.frontPassengerHeatCushionZone4)
        frontPassengerVentBackrest = .init(proto: proto.frontPassengerVentBackrest)
        frontPassengerVentCushion = .init(proto: proto.frontPassengerVentCushion)
        rearPassengerHeatLeft = .init(proto: proto.rearPassengerHeatLeft)
        rearPassengerHeatCenter = .init(proto: proto.rearPassengerHeatCenter)
        rearPassengerHeatRight = .init(proto: proto.rearPassengerHeatRight)
    }
}

enum SyncSet: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SyncSet) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum RearWindowHeatingStatus: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case offLostCommWithDcm // = 3
    case onLostCommWithDcm // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_RearWindowHeatingStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .offLostCommWithDcm: self = .offLostCommWithDcm
        case .onLostCommWithDcm: self = .onLostCommWithDcm
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SteeringHeaterStatus: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SteeringHeaterStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    } 
}

enum SteeringWheelHeaterLevel: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case steeringWheelHeaterLevel1 // = 2
    case steeringWheelHeaterLevel2 // = 3
    case steeringWheelHeaterLevel3 // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SteeringWheelHeaterLevel) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .steeringWheelHeaterLevel1: self = .steeringWheelHeaterLevel1
        case .steeringWheelHeaterLevel2: self = .steeringWheelHeaterLevel2
        case .steeringWheelHeaterLevel3: self = .steeringWheelHeaterLevel3
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum HvacLimited: Codable, Equatable {
    case unknown // = 0
    case off // = 1
    case on // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_HvacLimited) {
        switch proto {
        case .unknown: self = .unknown
        case .off: self = .off
        case .on: self = .on
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct HVACState: Codable, Equatable {
    let power: HvacPower
    var defrost: DefrostState
    let preconditionStatus: HvacPreconditionStatus
    let keepClimateStatus: KeepClimateStatus
    let maxAcStatus: MaxACState
    let seats: SeatClimateState
    let syncSet: SyncSet
    let rearWindowHeatingStatus: RearWindowHeatingStatus
    let steeringHeater: SteeringHeaterStatus
    let steeringHeaterLevel: SteeringWheelHeaterLevel
    let frontLeftSetTemperature: Double
    let hvacLimited: HvacLimited
    
    init(proto: Mobilegateway_Protos_HvacState) {
        power = .init(proto: proto.power)
        defrost = .init(proto: proto.defrost)
        preconditionStatus = .init(proto: proto.preconditionStatus)
        keepClimateStatus = .init(proto: proto.keepClimateStatus)
        maxAcStatus = .init(proto: proto.maxAcStatus)
        seats = .init(proto: proto.seats)
        syncSet = .init(proto: proto.syncSet)
        rearWindowHeatingStatus = .init(proto: proto.rearWindowHeatingStatus)
        steeringHeater = .init(proto: proto.steeringHeater)
        steeringHeaterLevel = .init(proto: proto.steeringHeaterLevel)
        frontLeftSetTemperature = proto.frontLeftSetTemperature
        hvacLimited = .init(proto: proto.hvacLimited)
    }
}

enum PrivacyMode: Codable, Equatable {
    case unknown // = 0
    case connectivityEnabled // = 1
    case connectivityDisabled // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PrivacyMode) {
        switch proto {
        case .unknown: self = .unknown
        case .connectivityEnabled: self = .connectivityEnabled
        case .connectivityDisabled: self = .connectivityDisabled
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum DriveMode: Codable, Equatable {
    case unknown // = 0
    case comfort // = 1
    case swift // = 2
    case winter // = 3
    case valet // = 4
    
    /// aka Sprint
    case sportPlus // = 5
    case reserved1 // = 6
    case reserved2 // = 7
    
    /// Service mode - car is in shop and can't be remote controlled
    case service // = 8
    case launch // = 9
    case factory // = 10
    case dev1 // = 11
    case dev2 // = 12
    case transport // = 13
    case showroom // = 14
    case tow // = 15
    case testDrive // = 16
    case reserved3 // = 17
    case UNRECOGNIZED(Int)
    
    init (proto: Mobilegateway_Protos_DriveMode) {
        switch proto {
        case .unknown: self = .unknown
        case .comfort: self = .comfort
        case .swift: self = .swift
        case .winter: self = .winter
            case .valet: self = .valet
        case .sportPlus: self = .sportPlus
        case .reserved1: self = .reserved1
        case .reserved2: self = .reserved2
            
        case .service: self = .service
        case .launch: self = .launch
        case .factory: self = .factory
        case .dev1: self = .dev1
        case .dev2: self = .dev2
        case .transport: self = .transport
        case .showroom: self = .showroom
        case .tow: self = .tow
        case .testDrive: self = .testDrive
        case .reserved3: self = .reserved3
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
