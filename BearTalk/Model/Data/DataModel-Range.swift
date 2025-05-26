//
//  DataModel-Range.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI

extension DataModel {
    func updateRangeStats() {
        guard let vehicle else { return }
        
        // Clamp battery percentage to 100% maximum
        let clampedBatteryPercent = min(vehicle.vehicleState.batteryState.chargePercent, 100.0)
        chargePercentage = "\(clampedBatteryPercent.rounded())%"
        kWh = vehicle.vehicleState.batteryState.kwHr.round(to: 2)
        
        // Calculate real-world range based on current battery level and efficiency
        let estimatedRangeInMiles = (kWh * lastEfficiency).rounded()
        
        // Convert to kilometers if needed based on locale
        let distanceUnit: UnitLength = Locale.current.measurementSystem == .metric ? .kilometers : .miles
        let rangeMeasurement = Measurement(value: estimatedRangeInMiles, unit: UnitLength.miles)
        let rangeMeasurementConverted = rangeMeasurement.converted(to: distanceUnit).formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))
        
        unitLabel = Locale.current.measurementSystem == .metric ? "km" : "mi"
        
        // Store the EPA range from vehicle state as a reference only
        let epaRangeMeasurement = Measurement(value: Double(vehicle.vehicleState.batteryState.remainingRange), unit: UnitLength.kilometers)
        range = epaRangeMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))
        
        // Store our calculated real-world range
        _estimatedRange = rangeMeasurementConverted
    }
}
