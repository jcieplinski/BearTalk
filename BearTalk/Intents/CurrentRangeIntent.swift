//
//  CurrentRangeIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct CurrentRangeIntent: AppIntent {
    static var title: LocalizedStringResource = "Calculate Range"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Current efficiency")
    var efficiency: Double

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })

        if let kWh = vehicle?.vehicleState.batteryState.kwHr {
            let range = (kWh * efficiency).rounded().stringWithLocale()

            return .result(dialog: "Your estimated range is \(range) miles.")
        }

        return .result(dialog: "Could not calculate. Please try again.")
    }
}
