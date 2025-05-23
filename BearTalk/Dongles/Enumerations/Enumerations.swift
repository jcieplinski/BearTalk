//
//  Enumerations.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import UniformTypeIdentifiers

enum DefaultsKey {
    static let authorization: String = "authorization"
    static let refreshToken: String = "refreshToken"
    static let password: String = "password"
    static let userName: String = "userName"
    static let vehicleID: String = "vehicleID"
    static let allVehicles: String = "allVehicles"
    static let carColor: String = "carColor"
    static let lastEfficiency: String = "lastEfficiency"
    static let controlsFavorites: String = "controlsFavorites"
    static let selectedTemperature: String = "selectedTemperature"
    static let seatClimateLevel: String = "seatClimateLevel"
}

enum LockState: Codable, Equatable {
    case unknown // = 0
    case unlocked // = 1
    case locked // = 2
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown:
            return 0
        case .locked:
            return 2
        case .unlocked:
            return 1
        case .UNRECOGNIZED(let int):
            return int
        }
    }

    var title: String {
        switch self {
        case .unknown:
            return "unknown"
        case .locked:
            return "Locked"
        case .unlocked:
            return "Unlocked"
        case .UNRECOGNIZED(let int):
            return "Unrecognized \(int)"
        }
    }

    var image: String {
        switch self {
        case .unknown:
            return "questionmark"
        case .locked:
            return "doorsLocked"
        case .unlocked:
            return "doorsUnlocked"
        case .UNRECOGNIZED(_):
            return "questionmark"
        }
    }
    
    init(proto: Mobilegateway_Protos_LockState) {
        switch proto {
        case .unknown:
            self = .unknown
        case .unlocked:
            self = .unlocked
        case .locked:
            self = .locked
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum Cargo {
    case frunk
    case trunk

    var controlURL: String {
        switch self {
        case .frunk:
            return .frunkControl
        case .trunk:
            return .trunkControl
        }
    }
}

enum ClosureState: String {
    case open = "OPEN"
    case closed = "CLOSED"
    case unknown = "UNKNOWN_CLOSURE_STATE"

    var frunkImage: String {
        switch self {
        case .open:
            return "frunkOpen"
        case .closed:
            return "frunkClosed"
        case .unknown:
            return "frunkClosed"
        }
    }

    var trunkImage: String {
        switch self {
        case .open:
            return "trunkOpen"
        case .closed:
            return "trunkClosed"
        case .unknown:
            return "trunkClosed"
        }
    }

    var chargePortImage: String {
        switch self {
        case .open:
            return "chargePortOpen"
        case .closed:
            return "chargePortClosed"
        case .unknown:
            return "chargePortClosed"

        }
    }
}

enum LightsAction: String {
    case on = "LIGHTS_ON"
    case off = "LIGHTS_OFF"
    case flash = "LIGHTS_FLASH"

    var lightsImage: String {
        switch self {
        case .on:
            return "lightsOn"
        case .off:
            return "lightsOff"
        case .flash:
            return "flashLightsOff"
        }
    }
}

enum DefrostAction: String {
    case on = "DEFROST_ON"
    case off = "DEFROST_OFF"

    var defrostImage: String {
        switch self {
        case .on:
            return "defrostOn"
        case .off:
            return "defrostOff"
        }
    }
}

enum Interior: Codable, Equatable {
    case unknown // = 0
    case santaCruz // = 1
    case tahoe // = 2
    case mojave // = 3
    case santaMonica // = 5
    case UNRECOGNIZED(Int)

    var title: String {
        switch self {
        case .unknown: return "Unknown"
        case .santaCruz: return "Santa Cruz"
        case .tahoe: return "Tahoe"
        case .mojave: return "Mojave"
        case .santaMonica: return "Santa Monica"
        case .UNRECOGNIZED(let int):
            return "Unrecognized(\(int))"
        }
    }
    
    var intValue: Int {
        switch self {
        case .unknown: return 0
        case .santaCruz: return 1
        case .tahoe: return 2
        case .mojave: return 3
        case .santaMonica: return 5
        case .UNRECOGNIZED(let int):
            return int
        }
    }
    
    init(proto: Mobilegateway_Protos_Interior) {
        switch proto {
            case .unknown:
            self = .unknown
        case .santaCruz:
            self = .santaCruz
        case .tahoe:
            self = .tahoe
        case .mojave:
            self = .mojave
        case .santaMonica:
            self = .santaMonica
        case .UNRECOGNIZED(let int):
            self = .UNRECOGNIZED(int)
        }
    }
}

enum Look: Codable, Equatable {
    case unknown // = 0
    case platinum // = 1
    case stealth // = 2
    case sapphire // = 3
    case surfrider // = 4
    case base // = 5
    case UNRECOGNIZED(Int)

    var title: String {
        switch self {
        case .unknown:
            "Unknown"
        case .platinum:
            "Platinum"
        case .stealth:
            "Stealth"
        case .sapphire:
            "Sapphire"
        case .surfrider:
            "Surfrider"
        case .base:
            "Base"
        case .UNRECOGNIZED(let int):
            "Unrecognized(\(int))"
        }
    }
    
    init(proto: Mobilegateway_Protos_Look) {
        switch proto {
        case .unknown: self = .unknown
        case .platinum: self = .platinum
        case .stealth: self = .stealth
        case .sapphire: self = .sapphire
        case .surfrider: self = .surfrider
        case .base: self = .base
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum Model: String {
    case air = "AIR"
    case gravity = "GRAVITY"

    var title: String {
        switch self {
        case .air:
            "Air"
        case .gravity:
            "Gravity"
        }
    }
}

enum Trim: String {
    case dreamEdition = "DREAM_EDITION"
    case grandTouring = "GRAND_TOURING"
    case grandTouringPerformance = "GRAND_TOURING_PERFORMANCE"
    case touring = "TOURING"
    case pure = "PURE"

    var title: String {
        switch self {
        case .dreamEdition:
            "Dream Edition"
        case .grandTouring:
            "Grand Touring"
        case .grandTouringPerformance:
            "Grand Touring Performance"
        case .touring:
            "Touring"
        case .pure:
            "Pure"
        }
    }
}

enum AppTab {
    case home
    case stats
    case map
    case range
}

enum FocusableField: Hashable {
    case userName
    case password
}

enum PowerImage: String {
    case sleep = "zzz"
    case awake = "parkingsign.circle"
}

enum GearPosition: Codable, Equatable {
    case gearUnknown // = 0
    case gearPark // = 1
    case gearReverse // = 2
    case gearNeutral // = 3
    case gearDrive // = 4
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_GearPosition) {
        switch proto {
        case .gearUnknown: self = .gearUnknown
        case .gearPark: self = .gearPark
        case .gearReverse: self = .gearReverse
        case .gearNeutral: self = .gearNeutral
        case .gearDrive: self = .gearDrive
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum ControlFunction {
    case doorLocks
    case frunk
    case trunk
    case chargePort
    case defrost
    case lights
    case flash
    case horn
    case wake
}

enum LucidModel: Codable, Equatable {
    case unknown // = 0
    case air // = 1
    case gravity // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_Model) {
        switch proto {
        case .unknown: self = .unknown
        case .air: self = .air
        case .gravity: self = .gravity
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
    
    var title: String {
        switch self {
        case .air:
            "Air"
        case .gravity:
            "Gravity"
        case .unknown:
            "Unknown"
        case .UNRECOGNIZED(let int):
            "Unknown (\(int))"
        }
    }
}

enum ModelVariant: Codable, Equatable {
    case unknown // = 0
    case dreamEdition // = 1
    case grandTouring // = 2
    case touring // = 3
    case pure // = 4
    case sapphire // = 5
    case hyper // = 6
    case executive // = 7
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_ModelVariant) {
        switch proto {
        case .unknown: self = .unknown
        case .dreamEdition: self = .dreamEdition
        case .grandTouring: self = .grandTouring
        case .touring: self = .touring
        case .pure: self = .pure
        case .sapphire: self = .sapphire
        case .hyper: self = .hyper
        case .executive: self = .executive
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
            
        }
    }
    
    var title: String {
        switch self {
        case .dreamEdition:
            "Dream Edition"
        case .grandTouring:
            "Grand Touring"
        case .hyper:
            "Grand Touring Performance"
        case .touring:
            "Touring"
        case .pure:
            "Pure"
        case .unknown:
            "Unknown"
        case .sapphire:
            "Sapphire"
        case .executive:
            "Executive"
        case .UNRECOGNIZED(_):
            "Unrecognized"
        }
    }
}

enum SeatAssignment: Codable, Equatable {
    case driverHeatBackrestZone1(mode: SeatClimateMode)
    case driverHeatBackrestZone3(mode: SeatClimateMode)
    case driverHeatCushionZone2(mode: SeatClimateMode)
    case driverHeatCushionZone4(mode: SeatClimateMode)
    case driverVentBackrest(mode: SeatClimateMode)
    case driverVentCushion(mode: SeatClimateMode)
    case frontPassengerHeatBackrestZone1(mode: SeatClimateMode)
    case frontPassengerHeatBackrestZone3(mode: SeatClimateMode)
    case frontPassengerHeatCushionZone2(mode: SeatClimateMode)
    case frontPassengerHeatCushionZone4(mode: SeatClimateMode)
    case frontPassengerVentBackrest(mode: SeatClimateMode)
    case frontPassengerVentCushion(mode: SeatClimateMode)
    case rearPassengerHeatLeft(mode: SeatClimateMode)
    case rearPassengerHeatCenter(mode: SeatClimateMode)
    case rearPassengerHeatRight(mode: SeatClimateMode)
}

extension UTType {
    static let controlType = UTType(exportedAs: "com.joecieplinski.bearTalk.controlType")
}

enum ControlType: String, Codable, Equatable, CaseIterable, Identifiable, Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .controlType)
    }
    
    case wake
    case doorLocks
    case frunk
    case trunk
    case chargePort
    case climateControl
    case maxAC
    case seatClimate
    case steeringWheelClimate
    case defrost
    case horn
    case lights
    case batteryPrecondition
    
    case driverSeatHeat
    case driverSeatVent
    case passengerSeatHeat
    case passengerSeatVent
    case rearLeftSeatHeat
    case rearCenterSeatHeat
    case rearRightSeatHeat
    
    var id: Self { self }
    
    static var allCases: [ControlType] {
        // We remove wake from allCases here. We don't want it as its own button
        return [.doorLocks, .frunk, .trunk, .chargePort, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .batteryPrecondition]
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .wake:
            "Wake Up"
        case .doorLocks:
            "Door Locks"
        case .frunk:
            "Frunk"
        case .trunk:
            "Trunk"
        case .chargePort:
            "Charge Port"
        case .defrost:
            "Defrost"
        case .maxAC:
            "Max AC"
        case .seatClimate:
            "Seat Climate"
        case .steeringWheelClimate:
            "Steering Wheel Heat"
        case .horn:
            "Honk Horn"
        case .lights:
            "Lights"
        case .batteryPrecondition:
            "Precondition Battery"
        case .climateControl:
            "Climate Control"
        case .driverSeatHeat:
            "Driver Seat Heat"
        case .driverSeatVent:
            "Driver Seat Vent"
        case .passengerSeatHeat:
            "Passenger Seat Heat"
        case .passengerSeatVent:
            "Passenger Seat Vent"
        case .rearLeftSeatHeat:
            "Rear Left Seat Heat"
        case .rearCenterSeatHeat:
            "Rear Center Seat Heat"
        case .rearRightSeatHeat:
            "Rear Right Seat Heat"
        }
    }
    
    var offImage: String {
        switch self {
        case .wake:
            ""
        case .doorLocks:
            "doorsUnlocked"
        case .frunk:
            "frunkClosed"
        case .trunk:
            "trunkClosed"
        case .chargePort:
            "chargePortClosed"
        case .defrost:
            "defrostOff"
        case .maxAC:
            "maxAcOff"
        case .seatClimate, .driverSeatHeat, .passengerSeatHeat, .rearLeftSeatHeat, .rearCenterSeatHeat, .rearRightSeatHeat:
            "seatClimateOff"
        case .driverSeatVent, .passengerSeatVent:
            "seatVentOff"
        case .steeringWheelClimate:
            "steeringWheelOff"
        case .horn:
            "hornOff"
        case .lights:
            "lightsOff"
        case .batteryPrecondition:
            "batteryOff"
        case .climateControl:
            "climateOff"
        }
    }
    
    var onImage: String {
        switch self {
        case .wake:
            ""
        case .doorLocks:
            "doorsLocked"
        case .frunk:
            "frunkOpen"
        case .trunk:
            "trunkOpen"
        case .chargePort:
            "chargePortOpen"
        case .defrost:
            "defrostOn"
        case .maxAC:
            "maxAcOn"
        case .seatClimate, .driverSeatHeat, .passengerSeatHeat, .rearLeftSeatHeat, .rearCenterSeatHeat, .rearRightSeatHeat:
            "seatClimateOn"
        case .driverSeatVent, .passengerSeatVent:
            "seatVentOn"
        case .steeringWheelClimate:
            "steeringWheelOn"
        case .horn:
            "hornOn"
        case .lights:
            "lightsOn"
        case .batteryPrecondition:
            "batteryOn"
        case .climateControl:
            "climateOn"
        }
    }
}
