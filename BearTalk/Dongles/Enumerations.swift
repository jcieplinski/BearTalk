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
}

enum LockState: String {
    case unknown = "UNKNOWN_LOCK_STATE"
    case locked = "LOCKED"
    case unlocked = "UNLOCKED"

    var title: String {
        switch self {
        case .unknown:
            return "unknown"
        case .locked:
            return "Locked"
        case .unlocked:
            return "Unlocked"
        }
    }

    var image: String {
        switch self {
        case .unknown:
            return "questionmark"
        case .locked:
            return "lock"
        case .unlocked:
            return "lock.open"
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

    var frunkImage: String {
        switch self {
        case .open:
            return "car.side.front.open"
        case .closed:
            return "car.side"
        }
    }

    var trunkImage: String {
        switch self {
        case .open:
            return "car.side.rear.open"
        case .closed:
            return "car.side"
        }
    }

    var chargePortImage: String {
        switch self {
        case .open:
            return "bolt"
        case .closed:
            return "powerplug"
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
            return "headlight.low.beam.fill"
        case .off:
            return "headlight.low.beam"
        case .flash:
            return "parkinglight"
        }
    }
}

enum DefrostAction: String {
    case on = "DEFROST_ON"
    case off = "DEFROST_OFF"

    var defrostImage: String {
        switch self {
        case .on:
            return "windshield.front.and.heat.waves"
        case .off:
            return "info.windshield"
        }
    }
}

enum CarColor: String {
    case eureka = "EUREKA_GOLD"
    case stellar = "STELLAR_WHITE"
    case quantum = "QUANTUM_GRAY"
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
}

enum AppTab {
    case home
    case stats
    case map
}
