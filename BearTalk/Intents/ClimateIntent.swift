//
//  ClimateIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import AppIntents

enum ClimateStatus: Int, AppEnum {
    case off
    case on
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Climate Power")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct ClimateIntent: AppIntent {
    static var title: LocalizedStringResource = "Climate Control"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Climate Power")
    var status: ClimateStatus
    
    @Parameter(title: "Temperature")
    var temperature: Double
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var power: HvacPower = .hvacOff
        
        if self.status == .on {
            power = .hvacPrecondition
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setClimateControlState(vehicleID: vehicleID, state: power, temperature: temperature)
        } else {
            let _ = try await BearAPI.setClimateControlState(state: power, temperature: temperature)
        }
        
        return .result()
    }
}
