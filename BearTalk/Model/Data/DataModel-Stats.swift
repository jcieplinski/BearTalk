//
//  DataModel-Stats.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI

extension DataModel {
    func getInfoString() async -> String {
        do {
            if let vehicle {
                var config = vehicle.vehicleConfig
                config.vin = ""
                config.emaId = ""
                config.chargingAccounts = []
                config.easubscription = EASubscription(name: "", expirationDate: "", startDate: "", status: "")
                config.regionCode = ""
                config.countryCode = ""
                config.nickname = ""
                
                let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(config)
                if let json = String(data: jsonData, encoding: String.Encoding.utf8) {
                    return json
                } else {
                    return ""
                }
            } else {
                return ""
            }
        } catch let error {
            print("could not convert vehicleInfo to json \(error)")
            return ""
        }
    }
    
    func updateStats() {
        guard let vehicle else { return }
        
        nickname = vehicle.vehicleConfig.nickname
        vin = vehicle.vehicleConfig.vin
        year = vehicle.vehicleConfig.releaseDate ?? "Unknown"
        model = vehicle.vehicleConfig.model.title
        trim = vehicle.vehicleConfig.modelVariant.title
        wheels = vehicle.vehicleConfig.wheels.title
        look = vehicle.vehicleConfig.look.title
        interior = vehicle.vehicleConfig.interior.title
        paintColor = vehicle.vehicleConfig.paintColor.title
        softwareVersion = vehicle.vehicleState.chassisState.softwareVersion
        
        let interiorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.interiorTemp, unit: UnitTemperature.celsius)
        let interiorTempMeasurementConverted = interiorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))
        
        let exteriorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.exteriorTemp, unit: UnitTemperature.celsius)
        let exteriorTempMeasurementConverted = exteriorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))
        
        interiorTemp = "\(interiorTempMeasurementConverted.value.rounded()) \(interiorTempMeasurementConverted.unit.symbol)"
        exteriorTemp = "\(exteriorTempMeasurementConverted.value.rounded()) \(exteriorTempMeasurementConverted.unit.symbol)"
        
        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"
        
        let rangeMeasurement = Measurement(value: Double(vehicle.vehicleState.batteryState.remainingRange), unit: UnitLength.kilometers)
        let rangeMeasurementConverted = rangeMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))
        
        range = rangeMeasurementConverted
        
        let odometerMeasurement = Measurement(value: Double(vehicle.vehicleState.chassisState.odometerKm), unit: UnitLength.kilometers)
        let odometerMeasurementConverted = odometerMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))
        
        odometer = odometerMeasurementConverted
        
        if let doorPlateNumber = vehicle.vehicleConfig.specialIdentifiers?["doorPlate"] {
            DENumber = doorPlateNumber
        }
    }
}
