import SwiftUI

struct ClimateControlSheet: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    @State private var temperature: Double = Locale.current.measurementSystem == .metric ? 22 : 72
    @State private var debouncedTask: Task<Void, Never>?
    @State private var isSettingTemperature = false
    @State private var isInitialSetup = true
    
    let modalPresented: Bool
    
    var powerIsOn: Bool {
        guard let climatePowerState = model.climatePowerState else { return false }
        
        return climatePowerState.isOn
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                HStack(spacing: 44) {
                    // Power Button
                    Button {
                        model.toggleClimateControl()
                    } label: {
                        ZStack {
                            Image(systemName: powerIsOn ? "power.circle.fill" : "power.circle")
                                .font(.system(size: 44))
                                .fontWeight(.thin)
                                .foregroundStyle(powerIsOn ? .active : .inactive)
                            
                            if model.requestInProgress.contains(.climateControl) {
                                ProgressView()
                                    .controlSize(.large)
                                    .foregroundStyle(.active)
                            }
                        }
                    }
                    .disabled(model.requestInProgress.contains(.climateControl) || model.allFunctionsDisable)
                    
                    // Temperature Picker
                    Picker("Temperature", selection: $temperature) {
                        ForEach(temperatureRange, id: \.self) { temp in
                            Text("\(Int(temp))°")
                                .tag(temp)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                    .onChange(of: temperature) { _, newValue in
                        // Skip API call during initial setup
                        guard !isInitialSetup else { return }
                        
                        // Cancel any existing debounced task
                        debouncedTask?.cancel()
                        
                        // Create a new debounced task
                        debouncedTask = Task {
                            // Wait for 1 second of no changes
                            try? await Task.sleep(for: .seconds(1))
                            
                            // Only proceed if the task wasn't cancelled
                            guard !Task.isCancelled else { return }
                            
                            // Wait for any in-flight temperature setting to complete
                            while isSettingTemperature {
                                try? await Task.sleep(for: .milliseconds(100))
                                guard !Task.isCancelled else { return }
                            }
                            
                            // Set the temperature
                            isSettingTemperature = true
                            model.setCabinTemperature(newValue)
                            isSettingTemperature = false
                        }
                    }
                }
                
                // Control Buttons
                HStack(spacing: 20) {
                    ControlButton(controlType: .defrost) { _ in
                        model.handleControlAction(.defrost)
                    }
                    
                    ControlButton(controlType: .maxAC) { _ in
                        model.handleControlAction(.maxAC)
                    }

                    creatureComfortButton
                    keepClimateButton
                }
                .padding(.top)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Climate Control")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if modalPresented {
                    ToolbarItem(placement: .topBarTrailing) {
                        if #available(iOS 26.0, *) {
                            Button(role: .confirm) {
                                dismiss()
                            }
                        } else {
                            Button("Done") {
                                dismiss()
                            }
                        }
                    }
                }
            }
            .onAppear {
                temperature = model.selectedTemperature
                // Set isInitialSetup to false after a brief delay to ensure the temperature change has been processed
                Task {
                    try? await Task.sleep(for: .milliseconds(100))
                    isInitialSetup = false
                }
            }
            .toolbarVisibility(modalPresented ? .hidden : .automatic, for: .navigationBar)
        }
        .presentationDetents([.fraction(0.4), .medium])
    }

    private var creatureComfortButton: some View {
        let isActive = model.creatureComfortIsOn

        return ZStack {
            Button {
                model.setCreatureComfort(enabled: !isActive)
            } label: {
                Label("Creature Comfort", systemImage: "pawprint")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24))
                    .frame(maxWidth: 44, maxHeight: 44)
                    .padding(4)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .foregroundStyle(isActive ? .active.opacity(0.2) : .clear)

                            RoundedRectangle(cornerRadius: 13)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        }
                    )
                    .tint(isActive ? .active : .inactive)
            }
            .disabled(model.requestInProgress.contains(.creatureComfort) || model.allFunctionsDisable)

            if model.requestInProgress.contains(.creatureComfort) {
                ProgressView()
                    .controlSize(.large)
                    .foregroundStyle(.active)
            }
        }
    }

    private var keepClimateButton: some View {
        let isActive = model.keepClimateIsOn

        return ZStack {
            Button {
                model.setKeepClimate(enabled: !isActive)
            } label: {
                Label("Keep Climate", systemImage: "thermometer")
                    .labelStyle(.iconOnly)
                    .font(.system(size: 24))
                    .frame(maxWidth: 44, maxHeight: 44)
                    .padding(4)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 13)
                                .foregroundStyle(isActive ? .active.opacity(0.2) : .clear)

                            RoundedRectangle(cornerRadius: 13)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        }
                    )
                    .tint(isActive ? .active : .inactive)
            }
            .disabled(model.requestInProgress.contains(.keepClimate) || model.allFunctionsDisable)

            if model.requestInProgress.contains(.keepClimate) {
                ProgressView()
                    .controlSize(.large)
                    .foregroundStyle(.active)
            }
        }
    }
    
    private var temperatureRange: [Double] {
        let currentTempUnit = UnitConverter.currentTemperatureUnit
        if currentTempUnit == .celsius {
            // Celsius range (15°C to 30°C)
            return Array(stride(from: 15.0, through: 30.0, by: 1.0)).reversed()
        } else {
            // Fahrenheit range (59°F to 86°F)
            return Array(stride(from: 59.0, through: 86.0, by: 1.0)).reversed()
        }
    }
}

#Preview {
    ClimateControlSheet(modalPresented: true)
        .environment(DataModel())
} 
