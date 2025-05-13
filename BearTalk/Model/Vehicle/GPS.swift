//
//  GPS.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct GPS: Codable, Equatable {
    let location: Location
    let hasLocation: Bool
    let elevation: Int32
    let positionTime: UInt64
    let headingPrecise: Double
    
    init(proto: Mobilegateway_Protos_Gps) {
        self.location = Location(proto: proto.location)
        self.hasLocation = proto.hasLocation
        self.elevation = proto.elevation
        self.positionTime = proto.positionTime
        self.headingPrecise = proto.headingPrecise
    }
}
