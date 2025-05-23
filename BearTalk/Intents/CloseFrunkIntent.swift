//
//  CloseFrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct CloseFrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Close Frunk"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .closed)
        return .result()
    }
}
