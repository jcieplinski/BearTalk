//
//  WakeIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct WakeIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Car"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        if let vehicleId = vehicle?.vehicleId {
            let _ = try await BearAPI.wakeUp(vehicleID: vehicleId)
        } else {
            let _ = try await BearAPI.wakeUp()
        }
        
        return .result(dialog: "Waking Car…")
    }
}
