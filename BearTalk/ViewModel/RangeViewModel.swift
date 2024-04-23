//
//  RangeViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 4/23/24.
//

import SwiftUI

@Observable final class RangeViewModel {
    @ObservationIgnored @AppStorage(DefaultsKey.lastEfficiency) var lastEfficiency: Double = 3.2

    var vehicle: Vehicle?
    var chargePercentage: String = ""
    var range: String = ""
    var estimatedRange: String = ""
    var realRange: String = ""
    var kWh: Double = 0.0
    var unitLabel: String = "mi"
    var efficiencyText: String = ""
    var showingEfficiencyPrompt: Bool = false

    func fetchVehicle() async {
        do {
            if let fetched = try await BearAPI.fetchCurrentVehicle() {
                vehicle = fetched
                updateStats()
            }
        } catch let error {
            print("Error fetching vehicle \(error)")
        }
    }

    func updateStats() {
        guard let vehicle else { return }

        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"
        kWh = vehicle.vehicleState.batteryState.kwHr.round(to: 2)

        let rangeMeasurement = Measurement(value: Double(vehicle.vehicleState.batteryState.range), unit: UnitLength.kilometers)
        let rangeMeasurementConverted = rangeMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))

        unitLabel = Locale.current.measurementSystem == .metric ? "km" : "mi"

        range = rangeMeasurementConverted
        estimatedRange = (kWh * lastEfficiency).rounded().stringWithLocale()
    }
}
