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
    
    func applyPaintColorOverride() {
        applyAppearanceOverrides()
    }

    func applyAppearanceOverrides() {
        let actual = actualSceneModel
        AppearanceOverrides.migrateLegacy(into: actual)
        let displayed = CarSceneModel.storedOverride ?? actual
        let ownsDisplayed = displayed == actual
        sceneModel = displayed

        let fallbackRoof = ownsDisplayed ? (vehicle?.vehicleConfig.roof ?? .glassCanopy) : .glassCanopy
        showGlassRoof = RoofType.resolved(
            for: displayed,
            ownsCar: ownsDisplayed,
            fallback: fallbackRoof
        ).showsGlassRoof

        if ownsDisplayed, let vehicle {
            switch vehicle.vehicleConfig.modelVariant {
            case .unknown, .UNRECOGNIZED, .touring, .pure:
                fancyMirrorCaps = false
            case .dreamEdition, .grandTouring, .sapphire, .hyper, .executive:
                fancyMirrorCaps = true
            }
        } else {
            fancyMirrorCaps = true
        }

        guard displayed != .sapphire else { return }

        PaintColor.customSceneModel = displayed
        paintColor = PaintColor.resolved(
            for: displayed,
            ownsCar: ownsDisplayed,
            fallback: vehicle?.vehicleConfig.paintColor ?? .stellarWhite
        )
        selectedInterior = Interior.resolved(
            for: displayed,
            ownsCar: ownsDisplayed,
            fallback: vehicle?.vehicleConfig.interior ?? .mojavePurluxe
        )
        showPlatinum = Look.resolved(
            for: displayed,
            ownsCar: ownsDisplayed,
            fallback: vehicle?.vehicleConfig.look ?? .platinum
        ).showsPlatinum
        selectedWheel = Wheels.resolved(
            for: displayed,
            ownsCar: ownsDisplayed,
            fallback: vehicle?.vehicleConfig.wheels ?? .range
        )
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
        switch vehicle.vehicleConfig.interior {
        case .unknown:
            let code = vehicle.vehicleConfig.interiorColorCode
            interior = code.isEmpty ? "Unknown" : "Unknown (\(code))"
        case .UNRECOGNIZED(let int):
            let code = vehicle.vehicleConfig.interiorColorCode
            interior = code.isEmpty ? "Unrecognized(\(int))" : "Unrecognized(\(int), \(code))"
        default:
            interior = vehicle.vehicleConfig.interior.title
        }
        print("Interior stats \(vehicle.vehicleConfig.nickname): display=\(interior) enum=\(vehicle.vehicleConfig.interior.title) raw=\(vehicle.vehicleConfig.interior.intValue) colorCode=\(vehicle.vehicleConfig.interiorColorCode.debugDescription)")
        applyPaintColorOverride()
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
