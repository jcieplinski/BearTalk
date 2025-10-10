import SwiftUI

enum BatteryDisplay: String, CaseIterable {
    case distance = "distance"
    case percentage = "percentage"
    
    var displayName: String {
        switch self {
        case .distance:
            return "Distance"
        case .percentage:
            return "Percentage"
        }
    }
}

enum DistanceUnit: String, CaseIterable {
    case miles = "miles"
    case kilometers = "kilometers"
    
    var displayName: String {
        switch self {
        case .miles:
            return "Miles"
        case .kilometers:
            return "Kilometers"
        }
    }
}

enum TemperatureUnit: String, CaseIterable {
    case fahrenheit = "fahrenheit"
    case celsius = "celsius"
    
    var displayName: String {
        switch self {
        case .fahrenheit:
            return "Fahrenheit"
        case .celsius:
            return "Celsius"
        }
    }
}

enum TirePressureUnit: String, CaseIterable {
    case psi = "psi"
    case kpa = "kpa"
    
    var displayName: String {
        switch self {
        case .psi:
            return "PSI"
        case .kpa:
            return "kPa"
        }
    }
}

struct UnitsView: View {
    @AppStorage(DefaultsKey.batteryDisplay, store: .appGroup) private var batteryDisplay: String = BatteryDisplay.percentage.rawValue
    @AppStorage(DefaultsKey.distanceUnit, store: .appGroup) private var distanceUnit: String = DistanceUnit.miles.rawValue
    @AppStorage(DefaultsKey.temperatureUnit, store: .appGroup) private var temperatureUnit: String = TemperatureUnit.fahrenheit.rawValue
    @AppStorage(DefaultsKey.tirePressureUnit, store: .appGroup) private var tirePressureUnit: String = TirePressureUnit.psi.rawValue
    
    var body: some View {
        List {
            Section("Battery Display") {
                Picker("Battery Display", selection: $batteryDisplay) {
                    ForEach(BatteryDisplay.allCases, id: \.rawValue) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Distance") {
                Picker("Distance Unit", selection: $distanceUnit) {
                    ForEach(DistanceUnit.allCases, id: \.rawValue) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Temperature") {
                Picker("Temperature Unit", selection: $temperatureUnit) {
                    ForEach(TemperatureUnit.allCases, id: \.rawValue) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section("Tire Pressure") {
                Picker("Tire Pressure Unit", selection: $tirePressureUnit) {
                    ForEach(TirePressureUnit.allCases, id: \.rawValue) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("Units")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        UnitsView()
    }
}
