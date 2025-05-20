//
//  Wheels.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import Foundation

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
