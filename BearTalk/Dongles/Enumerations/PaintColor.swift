//
//  PaintColor.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI
import BearTalkProto

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
    
    static func overrideChoices(for model: CarSceneModel) -> [PaintColor] {
        switch model {
        case .gravity:
            [
                .stellarWhite,
                .infiniteBlack,
                .cosmosSilver,
                .quantumGrey,
                .zenithRed,
                .fathomBlue,
                .lunarTitanium,
                .auroraGreen,
                .supernovaBronze,
                .glossBlackPrimary
            ]
        case .sapphire:
            [
                .eurekaGold,
                .stellarWhite,
                .infiniteBlack,
                .cosmosSilver,
                .quantumGrey,
                .zenithRed,
                .fathomBlue,
                .sapphireBlue
            ]
        case .air:
            [
                .eurekaGold,
                .stellarWhite,
                .infiniteBlack,
                .cosmosSilver,
                .quantumGrey,
                .zenithRed,
                .fathomBlue
            ]
        }
    }

    static var customSceneModel: CarSceneModel = .air

    static func storedOverride(for model: CarSceneModel) -> PaintColor? {
        let raw = UserDefaults.appGroup.string(forKey: DefaultsKey.scoped(DefaultsKey.carColorOverride, model: model)) ?? ""
        guard !raw.isEmpty, let color = PaintColor(overrideStorageKey: raw), color != .unknown else { return nil }
        if color == .custom { return color }
        return overrideChoices(for: model).contains(color) ? color : nil
    }

    static func resolved(for model: CarSceneModel, ownsCar: Bool, fallback: PaintColor) -> PaintColor {
        if let stored = storedOverride(for: model) { return stored }
        if !ownsCar, let preset = preset(for: model) { return preset }
        return fallback
    }

    static func preset(for model: CarSceneModel) -> PaintColor? {
        switch model {
        case .air: .stellarWhite
        case .gravity: .auroraGreen
        case .sapphire: nil
        }
    }

    static func customHex(for model: CarSceneModel) -> String {
        let stored = UserDefaults.appGroup.string(forKey: DefaultsKey.scoped(DefaultsKey.customPaintColor, model: model)) ?? ""
        return stored.isEmpty ? "CCCCCC" : stored
    }

    var overrideStorageKey: String {
        switch self {
        case .unknown:
            "unknown"
        case .eurekaGold:
            "eurekaGold"
        case .stellarWhite:
            "stellarWhite"
        case .infiniteBlack:
            "infiniteBlack"
        case .cosmosSilver:
            "cosmosSilver"
        case .quantumGrey:
            "quantumGrey"
        case .zenithRed:
            "zenithRed"
        case .fathomBlue:
            "fathomBlue"
        case .custom:
            "custom"
        case .sapphireBlue:
            "sapphireBlue"
        case .lunarTitanium:
            "lunarTitanium"
        case .auroraGreen:
            "auroraGreen"
        case .supernovaBronze:
            "supernovaBronze"
        case .glossBlackPrimary:
            "glossBlackPrimary"
        case .UNRECOGNIZED(let value):
            "unrecognized-\(value)"
        }
    }

    init?(overrideStorageKey: String) {
        switch overrideStorageKey {
        case "unknown":
            self = .unknown
        case "eurekaGold":
            self = .eurekaGold
        case "stellarWhite":
            self = .stellarWhite
        case "infiniteBlack":
            self = .infiniteBlack
        case "cosmosSilver":
            self = .cosmosSilver
        case "quantumGrey":
            self = .quantumGrey
        case "zenithRed":
            self = .zenithRed
        case "fathomBlue":
            self = .fathomBlue
        case "custom":
            self = .custom
        case "sapphireBlue":
            self = .sapphireBlue
        case "lunarTitanium":
            self = .lunarTitanium
        case "auroraGreen":
            self = .auroraGreen
        case "supernovaBronze":
            self = .supernovaBronze
        case "glossBlackPrimary":
            self = .glossBlackPrimary
        default:
            guard overrideStorageKey.hasPrefix("unrecognized-"),
                  let value = Int(overrideStorageKey.dropFirst("unrecognized-".count)) else {
                return nil
            }
            self = .UNRECOGNIZED(value)
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
            "#A6A298"
        case .quantumGrey:
            "#4E5257"
        case .zenithRed:
            "#4B1718"
        case .fathomBlue:
            "#687078"
        case .custom:
            PaintColor.customHex(for: PaintColor.customSceneModel)
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
