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
        paintColor = vehicle.vehicleConfig.paintColor
        softwareVersion = vehicle.vehicleState.chassisState.softwareVersion
        
        let currentTempUnit = UnitConverter.currentTemperatureUnit
        let interiorTempConverted = UnitConverter.convertTemperature(vehicle.vehicleState.cabinState.interiorTemp, from: .celsius, to: currentTempUnit)
        let exteriorTempConverted = UnitConverter.convertTemperature(vehicle.vehicleState.cabinState.exteriorTemp, from: .celsius, to: currentTempUnit)
        
        interiorTemp = UnitConverter.formatTemperature(interiorTempConverted, unit: currentTempUnit)
        exteriorTemp = UnitConverter.formatTemperature(exteriorTempConverted, unit: currentTempUnit)
        
        // Clamp battery percentage to 100% maximum
        let clampedBatteryPercent = min(vehicle.vehicleState.batteryState.chargePercent, 100.0)
        chargePercentage = "\(clampedBatteryPercent.rounded())%"
        
        let currentDistanceUnit = UnitConverter.currentDistanceUnit
        let rangeConverted = UnitConverter.convertDistance(Double(vehicle.vehicleState.batteryState.remainingRange), from: .kilometers, to: currentDistanceUnit)
        range = UnitConverter.formatDistance(rangeConverted, unit: currentDistanceUnit)
        
        let odometerConverted = UnitConverter.convertDistance(Double(vehicle.vehicleState.chassisState.odometerKm), from: .kilometers, to: currentDistanceUnit)
        odometer = UnitConverter.formatDistance(odometerConverted, unit: currentDistanceUnit)
        
        if let doorPlateNumber = vehicle.vehicleConfig.specialIdentifiers?["doorPlate"] {
            DENumber = doorPlateNumber
        }
    }
}
