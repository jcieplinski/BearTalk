//
//  BatteryPreconditionIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/23/25.
//

import AppIntents

struct BatteryPreconditionIntent: AppIntent {
    enum PreconditionStatus: Int, AppEnum {
        case off
        case on
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Battery Preconditioning")
        
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .off: DisplayRepresentation(title: "Off"),
            .on: DisplayRepresentation(title: "On")
        ]
    }
    
    static var title: LocalizedStringResource = "Battery Preconditioning"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Precondition Status")
    var status: PreconditionStatus
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var power: PreconditioningStatus = .batteryPreconOff
        
        if self.status == .on {
            power = .batteryPreconOn
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setBatteryPreCondition(vehicleID: vehicleID, status: power)
        } else {
            let _ = try await BearAPI.setBatteryPreCondition(status: power)
        }
        
        return .result()
    }
}

