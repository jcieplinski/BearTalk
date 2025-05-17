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
        
        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"
        kWh = vehicle.vehicleState.batteryState.kwHr.round(to: 2)
        
        let rangeMeasurement = Measurement(value: Double(vehicle.vehicleState.batteryState.remainingRange), unit: UnitLength.kilometers)
        let rangeMeasurementConverted = rangeMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))
        
        unitLabel = Locale.current.measurementSystem == .metric ? "km" : "mi"
        
        range = rangeMeasurementConverted
        estimatedRange = (kWh * lastEfficiency).rounded().stringWithLocale()
    }
}
