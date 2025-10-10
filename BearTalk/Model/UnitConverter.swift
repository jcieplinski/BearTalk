import Foundation

struct UnitConverter {
    
    // MARK: - Distance Conversion
    
    static func convertDistance(_ value: Double, from sourceUnit: DistanceUnit, to targetUnit: DistanceUnit) -> Double {
        let measurement: Measurement<UnitLength>
        
        switch sourceUnit {
        case .miles:
            measurement = Measurement(value: value, unit: UnitLength.miles)
        case .kilometers:
            measurement = Measurement(value: value, unit: UnitLength.kilometers)
        }
        
        switch targetUnit {
        case .miles:
            return measurement.converted(to: .miles).value
        case .kilometers:
            return measurement.converted(to: .kilometers).value
        }
    }
    
    static func formatDistance(_ value: Double, unit: DistanceUnit) -> String {
        let measurement: Measurement<UnitLength>
        
        switch unit {
        case .miles:
            measurement = Measurement(value: value, unit: UnitLength.miles)
        case .kilometers:
            measurement = Measurement(value: value, unit: UnitLength.kilometers)
        }
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 1
        
        return formatter.string(from: measurement)
    }
    
    // MARK: - Temperature Conversion
    
    static func convertTemperature(_ value: Double, from sourceUnit: TemperatureUnit, to targetUnit: TemperatureUnit) -> Double {
        let measurement: Measurement<UnitTemperature>
        
        switch sourceUnit {
        case .fahrenheit:
            measurement = Measurement(value: value, unit: UnitTemperature.fahrenheit)
        case .celsius:
            measurement = Measurement(value: value, unit: UnitTemperature.celsius)
        }
        
        switch targetUnit {
        case .fahrenheit:
            return measurement.converted(to: .fahrenheit).value
        case .celsius:
            return measurement.converted(to: .celsius).value
        }
    }
    
    static func formatTemperature(_ value: Double, unit: TemperatureUnit) -> String {
        let measurement: Measurement<UnitTemperature>
        
        switch unit {
        case .fahrenheit:
            measurement = Measurement(value: value, unit: UnitTemperature.fahrenheit)
        case .celsius:
            measurement = Measurement(value: value, unit: UnitTemperature.celsius)
        }
        
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.numberFormatter.maximumFractionDigits = 0
        
        return formatter.string(from: measurement)
    }
    
    // MARK: - Tire Pressure Conversion
    
    static func convertTirePressure(_ value: Double, from sourceUnit: TirePressureUnit, to targetUnit: TirePressureUnit) -> Double {
        switch (sourceUnit, targetUnit) {
        case (.psi, .kpa):
            return value * 6.89476 // PSI to kPa
        case (.kpa, .psi):
            return value / 6.89476 // kPa to PSI
        case (.psi, .psi), (.kpa, .kpa):
            return value
        }
    }
    
    static func formatTirePressure(_ value: Double, unit: TirePressureUnit) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 1
        formatter.numberStyle = .decimal
        formatter.locale = Locale.autoupdatingCurrent
        
        let formattedValue = formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedValue) \(unit.displayName)"
    }
    
    // MARK: - Current Unit Preferences
    
    static var currentBatteryDisplay: BatteryDisplay {
        let rawValue = UserDefaults.appGroup.string(forKey: DefaultsKey.batteryDisplay) ?? BatteryDisplay.percentage.rawValue
        return BatteryDisplay(rawValue: rawValue) ?? .percentage
    }
    
    static var currentDistanceUnit: DistanceUnit {
        let rawValue = UserDefaults.appGroup.string(forKey: DefaultsKey.distanceUnit) ?? DistanceUnit.miles.rawValue
        return DistanceUnit(rawValue: rawValue) ?? .miles
    }
    
    static var currentTemperatureUnit: TemperatureUnit {
        let rawValue = UserDefaults.appGroup.string(forKey: DefaultsKey.temperatureUnit) ?? TemperatureUnit.fahrenheit.rawValue
        return TemperatureUnit(rawValue: rawValue) ?? .fahrenheit
    }
    
    static var currentTirePressureUnit: TirePressureUnit {
        let rawValue = UserDefaults.appGroup.string(forKey: DefaultsKey.tirePressureUnit) ?? TirePressureUnit.psi.rawValue
        return TirePressureUnit(rawValue: rawValue) ?? .psi
    }
}
