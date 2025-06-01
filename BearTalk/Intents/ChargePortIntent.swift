//
//  ChargePortIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/30/25.
//

import AppIntents

struct ChargePortIntent: AppIntent {
    static var title: LocalizedStringResource = "Charge Port"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Action")
    var action: OpenAction
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var action: DoorState = .closed
        
        if self.action == .open {
            action = .open
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.chargePortControl(vehicleID: vehicleID, closureState: action)
        } else {
            let _ = try await BearAPI.chargePortControl(closureState: action)
        }
        
        return .result()
    }
}
