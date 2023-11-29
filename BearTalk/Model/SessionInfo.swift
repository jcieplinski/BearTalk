//
//  SessionInfo.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct SessionInfo: Codable {
    let idToken: String
    let expiryTimeSec: Int
    let refreshToken: String
    let gigyaJwt: String
}
