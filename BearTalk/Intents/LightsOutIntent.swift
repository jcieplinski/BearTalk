//
//  LightsOutIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/25/23.
//

import AppIntents

struct LightsOutIntent: AppIntent {
    static var title: LocalizedStringResource = "Car Lights Out"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.lightsControl(action: .off)
        return .result(dialog: "Shutting down all lights…")
    }
}
