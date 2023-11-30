//
//  MobileAppReqStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct MobileAppReqStatus: Codable, Equatable {
    let alarmSetReq: String
    let chargePortReq: String
    let chargeLockReq: String
    let doorLeftFrontReq: String
    let doorLeftRearReq: String
    let doorRightFrontReq: String
    let doorRightRearReq: String
    let driveEnable: String
    let frunkCargoReq: String
    let hornReq: String
    let hvacDefrostEnable: String
    let hvacPreconditionEnable: String
    let lightReq: String
    let panicReq: String
    let sharedTripReq: String
    let trunkCargoReq: String
    let vehicleUnlockReq: String
}
