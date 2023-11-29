//
//  VehicleState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleState: Codable {
    let batteryState: BatteryState
    let powerState: String
    let cabinState: CabinState
    var bodyState: BodyState
    let lastUpdatedMs: String
    let chassisState: ChassisState
    let chargingState: ChargingState
    let gps: GPS
    let softwareUpdate: SoftwareUpdate
    let alarmState: AlarmState
    let cloudConnectionState: String
    let keylessDrivingState: String
    let hvacStatus: HVACStatus
    let driveMode: String
    let privacyMode: String
    let gearPosition: String
    let mobileAppReqStatus: MobileAppReqStatus
    let tcuState: String
    let tcuInternetStatus: TCUInternetStatus
}
