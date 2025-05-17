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

enum Wheels: Codable, Equatable {
    case unknown // = 0
    case dream // = 1
    case blade // = 2
    case lite // = 3
    case range // = 4
    case sport // = 5
    case sportStealth // = 6
    case bladeGraphite // = 7
    case liteStealth // = 8
    case sportLuster // = 9
    case sapphirePackage // = 10
    case rangeStealth // = 11
    case UNRECOGNIZED(Int)

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
        case .sport:
            "21\" Performance"
        case .bladeGraphite:
            "21\" Aero Blade Graphite"
        case .liteStealth:
            "20\" Aero Lite Stealth"
        case .sportStealth:
            "21\" Performance Stealth"
        case .sportLuster:
            "Sport Luster"
        case .sapphirePackage:
            "20\" / 21\" Sapphire"
        case .rangeStealth:
            "19\" Aero Range Stealth"
        case .unknown:
            "Unknown"
        case .UNRECOGNIZED(let int):
            "Unrecognized: \(int)"
        }
    }
    
    init(proto: Mobilegateway_Protos_Wheels) {
        switch proto {
        case .unknown: self = .unknown
        case .dream: self = .dream
        case .blade: self = .blade
        case .bladeGraphite: self = .bladeGraphite
        case .lite: self = .lite
        case .liteStealth: self = .liteStealth
        case .range: self = .range
        case .rangeStealth: self = .rangeStealth
        case .sapphirePackage: self = .sapphirePackage
        case .sport: self = .sport
        case .sportLuster: self = .sportLuster
        case .sportStealth: self = .sportStealth
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

enum PaintColor: Codable, Equatable {
    case unknown // = 0
    case eurekaGold // = 1
    case stellarWhite // = 2
    case infiniteBlack // = 3
    case cosmosSilver // = 4
    case quantumGrey // = 5
    case zenithRed // = 6
    case fathomBlue // = 7
    case custom // = 8
    case sapphireBlue // = 9
    case lunarTitanium // = 10
    case auroraGreen // = 11
    case supernovaBronze // = 12
    case glossBlackPrimary // = 13
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_PaintColor) {
        switch proto {
        case .unknown: self = .unknown
        case .eurekaGold: self = .eurekaGold
        case .stellarWhite: self = .stellarWhite
        case .infiniteBlack: self = .infiniteBlack
        case .cosmosSilver: self = .cosmosSilver
        case .quantumGrey: self = .quantumGrey
        case .zenithRed: self = .zenithRed
        case .fathomBlue: self = .fathomBlue
        case .custom: self = .custom
        case .sapphireBlue: self = .sapphireBlue
        case .lunarTitanium: self = .lunarTitanium
        case .auroraGreen: self = .auroraGreen
        case .supernovaBronze: self = .supernovaBronze
        case .glossBlackPrimary: self = .glossBlackPrimary
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
    
    var image: String {
        switch self {
        case .eurekaGold:
            return "eureka"
        case .stellarWhite:
            return "stellar"
        case .quantumGrey:
            return "quantum"
        case .zenithRed:
            return "zenith"
        case .cosmosSilver:
            return "cosmos"
        case .infiniteBlack:
            return "infinite"
        case .fathomBlue:
            return "fathom"
        case .unknown:
            return "euereka"
        case .custom:
            return "stellar"
        case .sapphireBlue:
            return "stellar"
        case .lunarTitanium:
            return "stellar"
        case .auroraGreen:
            return "stellar"
        case .supernovaBronze:
            return "stellar"
        case .glossBlackPrimary:
            return "stellar"
        case .UNRECOGNIZED(_):
            return "stellar"
        }
    }
    
    var title: String {
        switch self {
        case .eurekaGold:
            return "Eureka Gold"
        case .stellarWhite:
            return "Stellar White"
        case .quantumGrey:
            return "Quantum Grey"
        case .zenithRed:
            return "Zenith Red"
        case .cosmosSilver:
            return "Cosmos Silver"
        case .infiniteBlack:
            return "Infinite Black"
        case .fathomBlue:
            return "Fathom Blue"
        case .unknown:
            return "Unknown"
        case .custom:
            return "Custom"
        case .sapphireBlue:
            return "Sapphire Blue"
        case .lunarTitanium:
            return "Lunar Titanium"
        case .auroraGreen:
            return "Aurora Green"
        case .supernovaBronze:
            return "Supernova Bronze"
        case .glossBlackPrimary:
            return "Gloss Black"
        case .UNRECOGNIZED(_):
            return "Unrecognized"
        }
    }
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
