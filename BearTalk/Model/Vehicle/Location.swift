//
//  Location.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct Location: Codable, Equatable {
    let latitude: Double
    let longitude: Double
    
    init(proto: Mobilegateway_Protos_Location) {
        self.latitude = proto.latitude
        self.longitude = proto.longitude
    }
}
