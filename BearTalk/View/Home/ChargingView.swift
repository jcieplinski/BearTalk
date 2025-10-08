import SwiftUI

struct ChargingView: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    @State private var chargeLimit: Double = 80
    @State private var debouncedTask: Task<Void, Never>?
    @State private var isSettingChargeLimit = false
    @State private var isInitialSetup = true
    
    // Custom binding to enforce minimum value
    private var chargeLimitBinding: Binding<Double> {
        Binding(
            get: { chargeLimit },
            set: { newValue in
                let clampedValue = max(50, min(100, newValue))
                let oldValue = chargeLimit
                chargeLimit = clampedValue
                
                // Check for haptic feedback points
                if clampedValue == 50 && oldValue != 50 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else if clampedValue == 80 && oldValue != 80 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } else if clampedValue == 100 && oldValue != 100 {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            }
        )
    }
    
    var chargePercentage: Double {
        model.vehicle?.vehicleState.batteryState.chargePercent.rounded() ?? 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    
                    Text("Current Charge: \(model.chargePercentage)")
                }
                .font(.title2)
                
                // Charging Status
                if let vehicle = model.vehicle {
                    ChargingStatusView(
                        chargingState: vehicle.vehicleState.chargingState.chargeState,
                        sessionMinutesRemaining: vehicle.vehicleState.chargingState.sessionMinutesRemaining
                    )
                }
                
                // Charge Limit Slider
                VStack(spacing: 16) {
                    HStack {
                        Text("Charge Limit")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(chargeLimit))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    
                    HStack {
                        Text("Charge Limit set below current charge. Charging will not start.")
                            .font(.caption)
                            .foregroundStyle(.red)
                        
                        Spacer()
                    }
                    .opacity(chargeLimit < chargePercentage ? 1 : 0)
                    
                    HStack {
                        Text("0%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Slider(value: chargeLimitBinding, in: 0...100, step: 1)
                            .onChange(of: chargeLimit) { _, newValue in
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
                                    
                                    // Wait for any in-flight charge limit setting to complete
                                    while isSettingChargeLimit {
                                        try? await Task.sleep(for: .milliseconds(100))
                                        guard !Task.isCancelled else { return }
                                    }
                                    
                                    // Set the charge limit
                                    isSettingChargeLimit = true
                                    model.setChargeLimit(UInt32(newValue))
                                    isSettingChargeLimit = false
                                }
                            }
                        
                        Text("100%")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if model.requestInProgress.contains(.chargeLimit) {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.active)
                            .transition(.scale)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Battery Preconditioning Button
                Button {
                    model.toggleBatteryPreconditioning()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Battery Preconditioning")
                                .font(.headline)
                            
                            Text(model.batteryPreConditionState == .batteryPreconOn ? "On" : "Off")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        ZStack {
                            Image(systemName: model.batteryPreConditionState == .batteryPreconOn ? "power.circle.fill" : "power.circle")
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .foregroundStyle(model.batteryPreConditionState == .batteryPreconOn ? .active : .inactive)
                            
                            if model.requestInProgress.contains(.batteryPrecondition) {
                                ProgressView()
                                    .controlSize(.large)
                                    .foregroundStyle(.active)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .disabled(model.requestInProgress.contains(.batteryPrecondition) || model.allFunctionsDisable)
            }
            .animation(.default, value: model.requestInProgress)
            .animation(.default, value: chargeLimit)
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Charging")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            // Set initial charge limit from model
            if let vehicle = model.vehicle {
                chargeLimit = vehicle.vehicleState.chargingState.chargeLimitPercent
            }
            
            // Set isInitialSetup to false after a brief delay
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                isInitialSetup = false
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChargingView()
            .environment(DataModel())
    }
} 
