//
//  ChassisState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct ChassisState: Codable {
    let odometer: Double
    let frontLeftTirePressBar: Double
    let frontRightTirePressBar: Double
    let rearLeftTirePressBar: Double
    let rearRightTirePressBar: Double
    let headlightState: String
    let indicatorState: String
    let hardWarnLeftFront: String
    let hardWarnLeftRear: String
    let hardWarnRightFront: String
    let hardWarnRightRear: String
    let softWarnLeftFront: String
    let softWarnLeftRear: String
    let softWarnRightFront: String
    let softWarnRightRear: String
    let softwareVersion: String
}
