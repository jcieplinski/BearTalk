//
//  ChargingState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct ChargingState: Codable {
    let chargeState: String
    let energyType: String
    let chargeSessionMi: Double
    let chargeSessionKwh: Double
    let sessionMinutesRemaining: Double
    let chargeLimit: Double
    let cableLock: String
    let chargeRateKwhPrecise: Double
    let chargeRateMphPrecise: Double
    let chargeRateMilesMinPrecise: Double
    let chargeLimitPercent: Double
    let chargeScheduledStatus: String
    let chargeScheduledTime: Double
    let scheduledChargeStatus: String
    let scheduledChargeUnavailableStatus: String
}
