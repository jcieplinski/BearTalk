//
//  GPS.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct GPS: Codable {
    let location: Location
    let elevation: Int
    let positionTime: String?
    let headingPrecise: Double
}
