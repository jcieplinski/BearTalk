//
//  VehicleConfig.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleConfig: Codable, Equatable {
    let vin: String
    let model: String
    let modelVariant: String
    let releaseDate: String?
    let nickname: String
    let paintColor: String
    let emaId: String
    let wheels: String
    let easubscription: EASubscription
    let chargingAccounts: [ChargingAccount]
    let countryCode: String
    let regionCode: String
    let edition: String
    let battery: String
    let interior: String
    let specialIdentifiers: [String]?
    let look: String
    let exteriorColorCode: String
    let interiorColorCode: String
    let frunkStrut: String

    static func empty() -> VehicleConfig {
        return VehicleConfig(
            vin: "50EA1TEA8PA002146",
            model: "AIR",
            modelVariant: "TOURING",
            releaseDate: nil,
            nickname: "Stella",
            paintColor: "STELLAR_WHITE",
            emaId: "USLCDCEGYHIY6X",
            wheels: "RANGE",
            easubscription: EASubscription(name: "EA", expirationDate: "1766600480", startDate: "1671906080", status: "CURRENT"),
            chargingAccounts: [],
            countryCode: "US",
            regionCode: "NA",
            edition: "EDITION_STANDARD",
            battery: "BATTERY_TYPE_01",
            interior: "SANTA_CRUZ",
            specialIdentifiers: nil,
            look: "PLATINUM",
            exteriorColorCode: "L102",
            interiorColorCode: "INT12",
            frunkStrut: "POWER_STRUT")
    }
}
