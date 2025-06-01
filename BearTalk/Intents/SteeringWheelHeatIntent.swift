//
//  SteeringWheelHeatIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import AppIntents

enum SteeringWheelHeatStatus: Int, AppEnum {
    case off
    case on
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Steering Wheel Heat")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct SteeringWheelHeatIntent: AppIntent {
    static var title: LocalizedStringResource = "Steering Wheel Heat"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Power")
    var status: SteeringWheelHeatStatus
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var power: SteeringHeaterStatus = .off
        
        if self.status == .on {
            power = .on
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setSteeringWheelHeat(vehicleID: vehicleID, status: power)
        } else {
            let _ = try await BearAPI.setSteeringWheelHeat(status: power)
        }
        
        return .result()
    }
}
