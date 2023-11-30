//
//  BatteryState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct BatteryState: Codable, Equatable {
    let range: Int
    let chargePercent: Double
    let kwHr: Double
    let capacityKwHr: Double
    let batteryHealth: String
    let lowChargeLevel: String
    let criticalChargeLevel: String
    let unavailableChargePercent: Double
    let batteryPreconStatus: String
    let batteryPreconTimeRemaining: Double
}
