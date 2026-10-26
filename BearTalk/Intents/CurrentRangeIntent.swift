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
    var efficiency: Double?

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        guard let kWh = vehicle?.vehicleState.batteryState.kwHr else {
            return .result(dialog: "Could not calculate. Please try again.")
        }

        let milesPerKWh: Double
        let usedRecentDriving: Bool
        if let efficiency {
            milesPerKWh = efficiency
            usedRecentDriving = false
        } else if let vehicleId = vehicle?.vehicleId, let observed = DataModel.observedMilesPerKWh(for: vehicleId) {
            milesPerKWh = observed
            usedRecentDriving = true
        } else {
            milesPerKWh = try await $efficiency.requestValue("What is your current efficiency, in miles per kWh?")
            usedRecentDriving = false
        }

        let range = (kWh * milesPerKWh).rounded().stringWithLocale()
        if usedRecentDriving {
            return .result(dialog: "Your estimated range is \(range) miles, based on recent driving.")
        }
        return .result(dialog: "Your estimated range is \(range) miles.")
    }
}
