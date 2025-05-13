//
//  MobileAppReqStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct MobileAppReqStatus: Codable, Equatable {
    let alarmSetRequest: AlarmMode
    let chargePortRequest: DoorState
    let frunkCargoRequest: DoorState
    let hornRequest: DoorState
    let hvacDefrost: DefrostState
    let hvacPrecondition: HvacPower
    let lightRequest: LightAction
    let panicRequest: PanicState
    let sharedTripRequest: SharedTripState
    let trunkCargoRequest: DoorState
    let vehicleUnlockRequest: LockState
    
    init(proto: Mobilegateway_Protos_MobileAppReqState) {
        alarmSetRequest = .init(proto: proto.alarmSetRequest)
        chargePortRequest = .init(proto: proto.chargePortRequest)
        frunkCargoRequest = .init(proto: proto.frunkCargoRequest)
        hornRequest = .init(proto: proto.hornRequest)
        hvacDefrost = .init(proto: proto.hvacDefrost)
        hvacPrecondition = .init(proto: proto.hvacPrecondition)
        lightRequest = .init(proto: proto.lightRequest)
        panicRequest = .init(proto: proto.panicRequest)
        sharedTripRequest = .init(proto: proto.sharedTripRequest)
        trunkCargoRequest = .init(proto: proto.trunkCargoRequest)
        vehicleUnlockRequest = .init(proto: proto.vehicleUnlockRequest)
    }
}
