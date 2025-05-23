//
//  CurrentElevationIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct CurrentElevationIntent: AppIntent {
    static var title: LocalizedStringResource = "Elevation"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        let nickname = vehicle?.vehicleConfig.nickname ?? "Your Car"

        if let elevation = vehicle?.vehicleState.gps.elevation {
            let elevationMeasurement = Measurement(value: Double(elevation), unit: UnitLength.centimeters)
            let elevation = elevationMeasurement.formatted(.measurement(width: .abbreviated, usage: .visibility).locale(Locale.autoupdatingCurrent))
            return .result(dialog: IntentDialog(stringLiteral: "\(nickname) is currently at \(elevation)."))
        } else {
            return .result(dialog: IntentDialog(stringLiteral: "Could not get \(nickname)s current elevation."))
        }
    }
}
