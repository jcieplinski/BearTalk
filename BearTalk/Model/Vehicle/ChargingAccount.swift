//
//  ChargingAccount.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct ChargingAccount: Codable, Equatable {
    let emaid: String
    let vehicleId: String
    let status: String
    let createdAtEpochSec: String
    let expiryOnEpocSec: String?
    let vendorName: String
}
