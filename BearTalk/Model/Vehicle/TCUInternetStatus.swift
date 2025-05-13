//
//  TCUInternetStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

enum LteType: Codable, Equatable {
    case unknown // = 0
    case lteType3G // = 1
    case lteType4G // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_LteType) {
        switch proto {
        case .unknown: self = .unknown
        case .lteType3G: self = .lteType3G
        case .lteType4G: self = .lteType4G
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum InternetStatus: Codable, Equatable {
    case unknown // = 0
    case internetDisconnected // = 1
    case internetConnected // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_InternetStatus) {
        switch proto {
        case .unknown: self = .unknown
        case .internetDisconnected: self = .internetDisconnected
        case .internetConnected: self = .internetConnected
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

struct TCUInternetStatus: Codable, Equatable {
    let lteType: LteType
    let lteStatus: InternetStatus
    let wifiStatus: InternetStatus
    let lteRssi: Int32
    let hasLteRssi: Bool
    let wifiRssi: Int32
    let hasWifiRssi: Bool
    
    init(proto: Mobilegateway_Protos_TcuInternetState) {
        lteType = .init(proto: proto.lteType)
        lteStatus = .init(proto: proto.lteStatus)
        wifiStatus = .init(proto: proto.wifiStatus)
        lteRssi = proto.lteRssi
        hasLteRssi = proto.hasLteRssi
        wifiRssi = proto.wifiRssi
        hasWifiRssi = proto.hasWifiRssi
    }
}
