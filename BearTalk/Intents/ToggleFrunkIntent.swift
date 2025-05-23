//
//  ToggleFrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct ToggleFrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Frunk"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        if let currentClosureState = ClosureState(rawValue: "vehicle.vehicleState.bodyState.frontCargo.rawValue") {
            switch currentClosureState {
            case .open:
                let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .closed)
                return .result(dialog: "Frunk closed")
            case .closed:
                let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .open)
                return .result(dialog: "Frunk open")
            case .unknown:
                break
            }
        }

        return .result(dialog: "Could not get current frunk state")
    }
}
