//
//  TCUInternetStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct TCUInternetStatus: Codable {
    let lteType: String
    let lteStatus: String
    let wifiStatus: String
    let lteRssi: Int
    let wifiRssi: Int
}
