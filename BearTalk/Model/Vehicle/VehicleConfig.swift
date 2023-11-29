//
//  VehicleConfig.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleConfig: Codable {
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
}
