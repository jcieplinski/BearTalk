//
//  VehicleConfig.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

struct VehicleConfig: Codable, Equatable {
    var vin: String
    let model: LucidModel
    let modelVariant: ModelVariant
    let releaseDate: String?
    var nickname: String
    let paintColor: PaintColor
    var emaId: String
    let wheels: Wheels
    var easubscription: EASubscription
    var chargingAccounts: [ChargingAccount]
    var countryCode: String
    var regionCode: String
    let edition: Edition
    let battery: String
    let interior: Interior
    let specialIdentifiers: [String: String]?
    let look: Look
    let roof: RoofType
    let exteriorColorCode: String
    let interiorColorCode: String
    let frunkStrut: String
    let frontSeatsHeating: FrontSeatsHeatingAvailability
    let frontSeatsVentilation: FrontSeatsVentilationAvailability
    let secondRowHeatedSeats: SecondRowHeatedSeatsAvailability
    let heatedSteeringWheel: HeatedSteeringWheelAvailability

    static func empty() -> VehicleConfig {
        return VehicleConfig(
            vin: "50EA1TEA8PA002146",
            model: LucidModel.air,
            modelVariant: ModelVariant.touring,
            releaseDate: nil,
            nickname: "Stella",
            paintColor: PaintColor.stellarWhite,
            emaId: "USLCDCEGYHIY6X",
            wheels: .range,
            easubscription: EASubscription(name: "EA", expirationDate: "1766600480", startDate: "1671906080", status: "CURRENT"),
            chargingAccounts: [],
            countryCode: "US",
            regionCode: "NA",
            edition: .standard,
            battery: "BATTERY_TYPE_01",
            interior: .santaCruz,
            specialIdentifiers: nil,
            look: .platinum,
            roof: .glassCanopy,
            exteriorColorCode: "L102",
            interiorColorCode: "INT12",
            frunkStrut: "POWER_STRUT",
            frontSeatsHeating: .frontSeatsHeatingUnknown,
            frontSeatsVentilation: .frontSeatsVentilationUnknown,
            secondRowHeatedSeats: .secondRowHeatedSeatsUnknown,
            heatedSteeringWheel: .heatedSteeringWheelUnknown)
    }
}

enum Edition: Codable, Equatable {
    case unknown // = 0
    case performance // = 1
    case range // = 2
    case standard // = 3
    case UNRECOGNIZED(Int)
    
    var title: String {
        switch self {
        case .unknown: return "Unknown"
        case .performance: return "Performance"
        case .range: return "Range"
        case .standard: return "Standard"
        case .UNRECOGNIZED(let int): return "Unrecognized(\(int))"
        }
    }
    
    init(proto: Mobilegateway_Protos_Edition) {
        switch proto {
        case .unknown: self = .unknown
        case .performance: self = .performance
        case .range: self = .range
        case .standard: self = .standard
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum RoofType: Codable, Equatable {
    case unknown // = 0
    case glassCanopy // = 1
    case metal // = 2
    case carbonFiber // = 3
    case UNRECOGNIZED(Int)
    
    var intValue: Int {
        switch self {
        case .unknown: return 0
        case .glassCanopy: return 1
        case .metal: return 2
        case .carbonFiber: return 3
        case .UNRECOGNIZED(let int): return int
        }
    }
    
    init(proto: Mobilegateway_Protos_RoofType) {
        switch proto {
        case .unknown: self = .unknown
        case .glassCanopy: self = .glassCanopy
        case .metal: self = .metal
        case .carbonFiber: self = .carbonFiber
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum FrontSeatsHeatingAvailability: Codable, Equatable {
    case frontSeatsHeatingUnknown // = 0
    case frontSeatsHeatingUnavailable // = 1
    case frontSeatsHeatingAvailable // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_FrontSeatsHeatingAvailability) {
        switch proto {
        case .frontSeatsHeatingUnknown: self = .frontSeatsHeatingUnknown
        case .frontSeatsHeatingUnavailable: self = .frontSeatsHeatingUnavailable
        case .frontSeatsHeatingAvailable: self = .frontSeatsHeatingAvailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum FrontSeatsVentilationAvailability: Codable, Equatable {
    case frontSeatsVentilationUnknown // = 0
    case frontSeatsVentilationUnavailable // = 1
    case frontSeatsVentilationAvailable // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_FrontSeatsVentilationAvailability) {
        switch proto {
        case .frontSeatsVentilationUnknown: self = .frontSeatsVentilationUnknown
        case .frontSeatsVentilationUnavailable: self = .frontSeatsVentilationUnavailable
        case .frontSeatsVentilationAvailable: self = .frontSeatsVentilationAvailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum SecondRowHeatedSeatsAvailability: Codable, Equatable {
    case secondRowHeatedSeatsUnknown // = 0
    case secondRowHeatedSeatsUnavailable // = 1
    case secondRowHeatedSeatsAvailable // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_SecondRowHeatedSeatsAvailability) {
        switch proto {
        case .secondRowHeatedSeatsUnknown: self = .secondRowHeatedSeatsUnknown
        case .secondRowHeatedSeatsUnavailable: self = .secondRowHeatedSeatsUnavailable
        case .secondRowHeatedSeatsAvailable: self = .secondRowHeatedSeatsAvailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}

enum HeatedSteeringWheelAvailability: Codable, Equatable {
    case heatedSteeringWheelUnknown // = 0
    case heatedSteeringWheelUnavailable // = 1
    case heatedSteeringWheelAvailable // = 2
    case UNRECOGNIZED(Int)
    
    init(proto: Mobilegateway_Protos_HeatedSteeringWheelAvailability) {
        switch proto {
        case .heatedSteeringWheelUnknown: self = .heatedSteeringWheelUnknown
        case .heatedSteeringWheelUnavailable: self = .heatedSteeringWheelUnavailable
        case .heatedSteeringWheelAvailable: self = .heatedSteeringWheelAvailable
        case .UNRECOGNIZED(let int): self = .UNRECOGNIZED(int)
        }
    }
}
