//
//  PaintColor.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

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
            return "Abyss Black"
        case .UNRECOGNIZED(_):
            return "Unrecognized"
        }
    }
    
    var color: Color {
        return Color(hex: hex) ?? .gray
    }
    
    var hex: String {
        switch self {
        case .unknown:
            "CCCCCC"
        case .eurekaGold:
            "#79786B"
        case .stellarWhite:
            "#F4F6ED"
        case .infiniteBlack:
            "#1F2022"
        case .cosmosSilver:
            "#A3A7B0"
        case .quantumGrey:
            "#4E5257"
        case .zenithRed:
            "#4B1718"
        case .fathomBlue:
            "#657286"
        case .custom:
            "CCCCCC"
        case .sapphireBlue:
            "012140"
        case .lunarTitanium:
            "#898781"
        case .auroraGreen:
            "#5a5b4e"
        case .supernovaBronze:
            "#413f38"
        case .glossBlackPrimary:
            "#070707"
        case .UNRECOGNIZED:
            "CCCCCC"
        }
    }
}
