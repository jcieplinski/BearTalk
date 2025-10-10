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
        
        // Convert to user's preferred distance unit
        let currentDistanceUnit = UnitConverter.currentDistanceUnit
        let rangeMeasurement = Measurement(value: estimatedRangeInMiles, unit: UnitLength.miles)
        let rangeMeasurementConverted = UnitConverter.convertDistance(estimatedRangeInMiles, from: .miles, to: currentDistanceUnit)
        let formattedRange = UnitConverter.formatDistance(rangeMeasurementConverted, unit: currentDistanceUnit)
        
        unitLabel = currentDistanceUnit == .kilometers ? "km" : "mi"
        
        // Store the EPA range from vehicle state as a reference only
        let epaRangeInKm = Double(vehicle.vehicleState.batteryState.remainingRange)
        let epaRangeConverted = UnitConverter.convertDistance(epaRangeInKm, from: .kilometers, to: currentDistanceUnit)
        range = UnitConverter.formatDistance(epaRangeConverted, unit: currentDistanceUnit)
        
        // Store our calculated real-world range
        _estimatedRange = formattedRange
    }
}
