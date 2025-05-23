//
//  OpenTrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct OpenTrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Trunk"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .trunk, closureState: .open)
        return .result()
    }
}
