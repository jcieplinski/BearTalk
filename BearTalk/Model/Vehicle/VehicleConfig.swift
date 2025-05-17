//
//  VehicleConfig.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleConfig: Codable, Equatable {
    var vin: String
    let model: LucidModel
    let modelVariant: ModelVariant
    let releaseDate: String?
    var nickname: String
    let paintColor: PaintColor
    var emaId: String
    let wheels: Wheels
    var easubscription: EASubscription
    var chargingAccounts: [ChargingAccount]
    var countryCode: String
    var regionCode: String
    let edition: Edition
    let battery: String
    let interior: Interior
    let specialIdentifiers: [String: String]?
    let look: Look
    let exteriorColorCode: String
    let interiorColorCode: String
    let frunkStrut: String

    static func empty() -> VehicleConfig {
        return VehicleConfig(
            vin: "50EA1TEA8PA002146",
            model: LucidModel.air,
            modelVariant: ModelVariant.touring,
            releaseDate: nil,
            nickname: "Stella",
            paintColor: PaintColor.stellarWhite,
            emaId: "USLCDCEGYHIY6X",
            wheels: .range,
            easubscription: EASubscription(name: "EA", expirationDate: "1766600480", startDate: "1671906080", status: "CURRENT"),
            chargingAccounts: [],
            countryCode: "US",
            regionCode: "NA",
            edition: .standard,
            battery: "BATTERY_TYPE_01",
            interior: .santaCruz,
            specialIdentifiers: nil,
            look: .platinum,
            exteriorColorCode: "L102",
            interiorColorCode: "INT12",
            frunkStrut: "POWER_STRUT")
    }
}

enum Edition: Codable, Equatable {
    case unknown // = 0
    case performance // = 1
    case range // = 2
    case standard // = 3
    case UNRECOGNIZED(Int)
    
    var title: String {
        switch self {
        case .unknown: return "Unknown"
        case .performance: return "Performance"
        case .range: return "Range"
        case .standard: return "Standard"
        case .UNRECOGNIZED(let int): return "Unrecognized(\(int))"
        }
    }
    
    init(proto: Mobilegateway_Protos_Edition) {
        switch proto {
        case .unknown: self = .unknown
        case .performance: self = .performance
        case .range: self = .range
        case .standard: self = .standard
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
