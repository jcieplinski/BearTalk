//
//  DefaultsKey.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/30/25.
//

import Foundation

enum DefaultsKey {
    static let authorization: String = "authorization"
    static let refreshToken: String = "refreshToken"
    static let tokenExpiryTime: String = "tokenExpiryTime"
    static let password: String = "password"
    static let userName: String = "userName"
    static let deviceID: String = "deviceID"
    static let vehicleID: String = "vehicleID"
    static let allVehicles: String = "allVehicles"
    static let carColor: String = "carColor"
    static let carColorOverride: String = "carColorOverride"
    static let customPaintColor: String = "customPaintColor"
    static let carModelOverride: String = "carModelOverride"

    static func scoped(_ base: String, model: CarSceneModel) -> String {
        "\(base).\(model.rawValue)"
    }
    static let interiorOverride: String = "interiorOverride"
    static let lookOverride: String = "lookOverride"
    static let wheelsOverride: String = "wheelsOverride"
    static let roofOverride: String = "roofOverride"
    static let lastEfficiency: String = "lastEfficiency"
    static let efficiencyLogs: String = "efficiencyLogs"
    static let controlsFavorites: String = "controlsFavorites"
    static let selectedTemperature: String = "selectedTemperature"
    static let seatClimateLevel: String = "seatClimateLevel"
    static let photoURL: String = "photoURL"
    static let cellOrder: String = "cellOrder"
    static let useFaceID: String = "useFaceID"
    static let colorScheme: String = "colorScheme"
    static let showAlertsBeforeOpenActions = "showAlertsBeforeOpenActions"
    static let lastDismissedSoftwareVersion = "lastDismissedSoftwareVersion"
    static let batteryDisplay: String = "batteryDisplay"
    static let distanceUnit: String = "distanceUnit"
    static let temperatureUnit: String = "temperatureUnit"
    static let tirePressureUnit: String = "tirePressureUnit"
    static let allControlsOrder: String = "allControlsOrder"
    static let cachedWidgetVehicleData: String = "cachedWidgetVehicleData"
    static let cameraState: String = "cameraState"
}
