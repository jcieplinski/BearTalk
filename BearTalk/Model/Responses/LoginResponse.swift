//
//  LoginResponse.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct LoginResponse: Codable {
    let uid: String
    let sessionInfo: SessionInfo
    let userProfile: UserProfile
    let userVehicleData: [Vehicle]
    let encryption: String
}
