//
//  EASubscription.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct EASubscription: Codable, Equatable {
    let name: String
    let expirationDate: String
    let startDate: String
    let status: String
}
