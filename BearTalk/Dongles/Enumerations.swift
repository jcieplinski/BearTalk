//
//  Enumerations.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

enum DefaultsKey {
    static let authorization: String = "authorization"
    static let refreshToken: String = "refreshToken"
    static let password: String = "password"
    static let userName: String = "userName"
    static let vehicleID: String = "vehicleID"
    static let carColor: String = "carColor"
    static let lastEfficiency: String = "lastEfficiency"
}

enum LockState: Codable, Equatable {
    case unknown
    case locked
    case unlocked
    case UNRECOGNIZED(Int)

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

enum CarColor: String {
    case eureka = "EUREKA_GOLD"
    case stellar = "STELLAR_WHITE"
    case quantum = "QUANTUM_GREY"
    case zenith = "ZENITH_RED"
    case cosmos = "COSMOS_SILVER"
    case infinite = "INFINITE_BLACK"
    case fathom = "FATHOM_BLUE"

    var image: String {
        switch self {
        case .eureka:
            return "eureka"
        case .stellar:
            return "stellar"
        case .quantum:
            return "quantum"
        case .zenith:
            return "zenith"
        case .cosmos:
            return "cosmos"
        case .infinite:
            return "infinite"
        case .fathom:
            return "fathom"
        }
    }

    var title: String {
        switch self {
        case .eureka:
            return "Eureka Gold"
        case .stellar:
            return "Stellar White"
        case .quantum:
            return "Quantum Grey"
        case .zenith:
            return "Zenith Red"
        case .cosmos:
            return "Cosmos Silver"
        case .infinite:
            return "Infinite Black"
        case .fathom:
            return "Fathom Blue"
        }
    }
}

enum Interior: String {
    case santaCruz = "SANTA_CRUZ"
    case mojave = "MOJAVE"
    case tahoe = "TAHOE"
    case santaMonica = "SANTA_MONICA"

    var title: String {
        switch self {
        case .santaCruz:
            "Santa Cruz"
        case .mojave:
            "Mojave"
        case .tahoe:
            "Tahoe"
        case .santaMonica:
            "Santa Monica"
        }
    }
}

enum Look: String {
    case platinum = "PLATINUM"
    case stealth = "STEALTH"

    var title: String {
        switch self {
        case .platinum:
            "Platinum"
        case .stealth:
            "Stealth"
        }
    }
}

enum Wheels: String {
    case range = "RANGE"
    case lite = "LITE"
    case blade = "BLADE"
    case dream = "DREAM"
    case performance = "PERFORMANCE"
    case bladeGraphite = "BLADE_GRAPHITE"
    case liteStealth = "LITE_STEALTH"

    var title: String {
        switch self {
        case .range:
            "19\" Aero Range"
        case .lite:
            "20\" Areo Lite"
        case .blade:
            "21\" Aero Blade"
        case .dream:
            "21\" Dream"
        case .performance:
            "21\" Performance"
        case .bladeGraphite:
            "21\" Aero Blade Graphite"
        case .liteStealth:
            "20\" Aero Lite Stealth"
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
