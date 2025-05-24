import SwiftUI

struct ClimateControlView: View {
    @Environment(DataModel.self) var model: DataModel
    @Environment(\.dismiss) var dismiss
    
    @State private var temperature: Double = Locale.current.measurementSystem == .metric ? 22 : 72
    @State private var debouncedTask: Task<Void, Never>?
    @State private var isSettingTemperature = false
    @State private var isInitialSetup = true
    
    var powerIsOn: Bool {
        guard let climatePowerState = model.climatePowerState else { return false }
        return climatePowerState.isOn
    }
    
    var body: some View {
        ScrollView {
            Section {
                ClimateControlSheet(modalPresented: false)
                    .padding(.horizontal)
            }
            
            Section {
                SeatClimateSheet(modalPresented: false)
                    .padding(.horizontal)
            } header: {
                HStack {
                    Text("Seats")
                        .font(.headline)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Climate")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            temperature = model.selectedTemperature
            // Set isInitialSetup to false after a brief delay to ensure the temperature change has been processed
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                isInitialSetup = false
            }
        }
    }
    
    private var temperatureRange: [Double] {
        if Locale.current.measurementSystem == .metric {
            // Celsius range (15°C to 30°C)
            return Array(stride(from: 15.0, through: 30.0, by: 1.0)).reversed()
        } else {
            // Fahrenheit range (59°F to 86°F)
            return Array(stride(from: 59.0, through: 86.0, by: 1.0)).reversed()
        }
    }
}

#Preview {
    NavigationStack {
        ClimateControlView()
            .environment(DataModel())
    }
} 
