//
//  Wheels.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import Foundation
import BearTalkProto

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
    case dreamMagnesium // = 12
    case aether // = 13
    case orion // = 14
    case voyager // = 15
    case UNRECOGNIZED(Int)
    
    var nodeTitle: String {
        switch self {
        case .range: "Wheel_Aero19"
        case .blade: "Wheel_AeroBlade21"
        case .lite: "Wheel_AeroLite20"
        case .sport: "Wheel_AeroSport21"
        case .dream: "Wheel_Dream21"
        case .unknown:
            ""
        case .sportStealth: "Wheel_AeroSport21"
        case .bladeGraphite: "Wheel_AeroBlade21"
        case .liteStealth: "Wheel_AeroLite20"
        case .sportLuster:
            ""
        case .sapphirePackage:
            ""
        case .rangeStealth: "Wheel_Aero19"
        case .dreamMagnesium: "Wheel_Dream21"
        case .aether: "Wheel_Set1_Aether"
        case .orion: "Wheel_Set2_Orion"
        case .voyager: "Wheel_Set3_Voyager"
        case .UNRECOGNIZED(_):
            ""
        }
    }

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
        case .dreamMagnesium:
            "21\" Dream Magnesium"
        case .aether:
            "22\" / 23\" Aether"
        case .orion:
            "21\" / 22\" Orion"
        case .voyager:
            "20\" / 21\" Voyager"
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
        case .dreamMagnesium: self = .dreamMagnesium
        case .aether: self = .aether
        case .orion: self = .orion
        case .voyager: self = .voyager
        }
    }

    static func overrideChoices(for model: CarSceneModel) -> [Wheels] {
        switch model {
        case .gravity:
            [.voyager, .orion, .aether]
        case .air, .sapphire:
            [
                .range,
                .rangeStealth,
                .lite,
                .liteStealth,
                .blade,
                .bladeGraphite,
                .sport,
                .sportStealth,
                .dream,
                .dreamMagnesium
            ]
        }
    }

    static func storedOverride(for model: CarSceneModel) -> Wheels? {
        let raw = UserDefaults.appGroup.string(forKey: DefaultsKey.scoped(DefaultsKey.wheelsOverride, model: model)) ?? ""
        guard !raw.isEmpty, let wheels = Wheels(overrideStorageKey: raw), overrideChoices(for: model).contains(wheels) else { return nil }
        return wheels
    }

    static func resolved(for model: CarSceneModel, ownsCar: Bool, fallback: Wheels) -> Wheels {
        if let stored = storedOverride(for: model) { return stored }
        if !ownsCar, let preset = preset(for: model) { return preset }
        return fallback
    }

    static func preset(for model: CarSceneModel) -> Wheels? {
        switch model {
        case .air: .range
        case .gravity: .aether
        case .sapphire: nil
        }
    }

    var overrideStorageKey: String {
        switch self {
        case .unknown: "unknown"
        case .dream: "dream"
        case .blade: "blade"
        case .lite: "lite"
        case .range: "range"
        case .sport: "sport"
        case .sportStealth: "sportStealth"
        case .bladeGraphite: "bladeGraphite"
        case .liteStealth: "liteStealth"
        case .sportLuster: "sportLuster"
        case .sapphirePackage: "sapphirePackage"
        case .rangeStealth: "rangeStealth"
        case .dreamMagnesium: "dreamMagnesium"
        case .aether: "aether"
        case .orion: "orion"
        case .voyager: "voyager"
        case .UNRECOGNIZED(let value): "unrecognized-\(value)"
        }
    }

    init?(overrideStorageKey: String) {
        switch overrideStorageKey {
        case "unknown": self = .unknown
        case "dream": self = .dream
        case "blade": self = .blade
        case "lite": self = .lite
        case "range": self = .range
        case "sport": self = .sport
        case "sportStealth": self = .sportStealth
        case "bladeGraphite": self = .bladeGraphite
        case "liteStealth": self = .liteStealth
        case "sportLuster": self = .sportLuster
        case "sapphirePackage": self = .sapphirePackage
        case "rangeStealth": self = .rangeStealth
        case "dreamMagnesium": self = .dreamMagnesium
        case "aether": self = .aether
        case "orion": self = .orion
        case "voyager": self = .voyager
        default:
            guard overrideStorageKey.hasPrefix("unrecognized-"),
                  let value = Int(overrideStorageKey.dropFirst("unrecognized-".count)) else {
                return nil
            }
            self = .UNRECOGNIZED(value)
        }
    }

}
