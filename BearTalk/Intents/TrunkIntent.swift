//
//  TrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/23/25.
//

import AppIntents

struct TrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Trunk"
    
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
            let _ = try await BearAPI.cargoControl(vehicleID: vehicleID, area: .trunk, closureState: action)
        } else {
            let _ = try await BearAPI.cargoControl(area: .trunk, closureState: action)
        }
        
        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
