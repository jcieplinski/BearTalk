//
//  CabinState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct CabinState: Codable, Equatable {
    let interiorTemp: Double
    let exteriorTemp: Double
    
    init(proto: Mobilegateway_Protos_CabinState) {
        interiorTemp = proto.interiorTemp
        exteriorTemp = proto.exteriorTemp
    }
}
