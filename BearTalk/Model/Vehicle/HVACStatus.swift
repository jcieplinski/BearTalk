//
//  HVACStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct HVACStatus: Codable, Equatable {
    let powerMode: String
    let defrost: String
    let preconditionStatus: String
}
