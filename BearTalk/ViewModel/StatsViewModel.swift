//
//  StatsViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

@Observable final class StatsViewModel {
    var vehicle: Vehicle?
    var noVehicleWarning: String = ""
    var nickname: String = ""
    var vin: String = ""
    var year: String = ""
    var model: String = ""
    var trim: String = ""
    var wheels: String = ""
    var odometer: String = ""
    var look: String = ""
    var interior: String = ""
    var paintColor: String = ""
    var interiorTemp: String = ""
    var exteriorTemp: String = ""
    var softwareVersion: String = ""
    var chargePercentage: String = ""
    var range: String = ""

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
        odometer = "\(vehicle.vehicleState.chassisState.odometer.rounded())"
        year = vehicle.vehicleConfig.releaseDate ?? "Unknown"
        model = Model(rawValue: vehicle.vehicleConfig.model)?.title ?? "Unknown"
        trim = Trim(rawValue: vehicle.vehicleConfig.modelVariant)?.title ?? "Unknown"
        wheels = Wheels(rawValue: vehicle.vehicleConfig.wheels)?.title ?? "Unknown"
        look = Look(rawValue: vehicle.vehicleConfig.look)?.title ?? "Unknown"
        interior = Interior(rawValue: vehicle.vehicleConfig.interior)?.title ?? "Unknown"
        paintColor = CarColor(rawValue: vehicle.vehicleConfig.paintColor)?.title ?? "Unknown"
        softwareVersion = vehicle.vehicleState.chassisState.softwareVersion

        let interiorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.interiorTemp, unit: UnitTemperature.celsius)
        let interiorTempMeasurementConverted = interiorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))

        let exteriorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.exteriorTemp, unit: UnitTemperature.celsius)
        let exteriorTempMeasurementConverted = exteriorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))

        interiorTemp = "\(interiorTempMeasurementConverted.value.rounded()) \(interiorTempMeasurementConverted.unit.symbol)"
        exteriorTemp = "\(exteriorTempMeasurementConverted.value.rounded()) \(exteriorTempMeasurementConverted.unit.symbol)"

        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"

        let rangeMeasurement = Measurement(value: Double(vehicle.vehicleState.batteryState.range), unit: UnitLength.kilometers)
        let rangeMeasurementConverted = rangeMeasurement.formatted(.measurement(width: .abbreviated, usage: .road).locale(Locale.autoupdatingCurrent))

        range = rangeMeasurementConverted
    }

    func fetchVehicle() async {
        do {
            if let fetched = try await BearAPI.fetchVehicles() {
                vehicle = fetched
                updateStats()
            }
        } catch let error {
            print("Error fetching vehicles \(error)")
            noVehicleWarning = "No vehicles found"
        }
    }

    // MARK: - Preview
    static var preview: StatsViewModel {
        let model = StatsViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
