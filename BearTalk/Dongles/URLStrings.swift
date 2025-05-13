//
//  URLStrings.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

extension String {
    // URLS for API
    static let baseAPI = "https://mobile.deneb.prod.infotainment.pdx.atieva.com/v1/"
    static let grpcAPI = "mobile.deneb.prod.infotainment.pdx.atieva.com"
    static let login = "login"
    static let refreshToken = "get_new_jwt_token"
    static let wakeUp = "wakeup"
    static let honkHorn = "honk_horn"
    static let doorLocksControl = "door_locks_control"
    static let frunkControl = "front_cargo_control"
    static let trunkControl = "rear_cargo_control"
    static let chargePortControl = "charge_port_control"
    static let userVehicles = "user_vehicles"
    static let lightsControl = "lights_control"
    static let defrostControl = "defrost_control"
}
