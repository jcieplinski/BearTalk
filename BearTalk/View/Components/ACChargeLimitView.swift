import SwiftUI

struct ACChargeLimitView: View {
    @Environment(DataModel.self) var model
    
    @State private var acCurrentLimit: Int32 = 0
    @State private var isInitialSetup = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AC Charge Limit")
                    .font(.headline)
                
                Spacer()
                
                Text("\(acCurrentLimit)A")
                    .font(.title2)
                    .fontWeight(.bold)
                    .monospacedDigit()
            }
            
            HStack(spacing: 20) {
                Button {
                    adjustACLimit(by: -5)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.active)
                }
                .buttonStyle(.plain)
                .disabled(model.requestInProgress.contains(.acCurrentLimit) || model.allFunctionsDisable)
                
                Spacer()
                
                if model.requestInProgress.contains(.acCurrentLimit) {
                    ProgressView()
                        .controlSize(.large)
                        .foregroundStyle(.active)
                        .transition(.scale)
                }
                
                Spacer()
                
                Button {
                    adjustACLimit(by: 5)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.active)
                }
                .buttonStyle(.plain)
                .disabled(model.requestInProgress.contains(.acCurrentLimit) || model.allFunctionsDisable)
            }
            
            // Show charging session info
            if let vehicle = model.vehicle {
                if vehicle.vehicleState.chargingState.chargeState == .charging,
                   vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit > 0 {
                    HStack {
                        Text("Current session: \(vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit)A")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    // Note: Due to current car firmware limitations, AC current limit changes 
                    // made via the app typically apply to the next charging session, not the current one
                }
            }
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            updateACLimitFromModel()
            
            // Set isInitialSetup to false after a brief delay
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                isInitialSetup = false
            }
        }
        .onChange(of: model.vehicle?.vehicleState.chargingState.energyAcCurrentLimit) { _, newValue in
            
            // Update the local state when the model changes
            if !isInitialSetup {
                updateACLimitFromModel()
            }
        }
        .onChange(of: model.vehicle?.vehicleState.mobileAppReqStatus.acCurrentLimitReq) { _, newValue in
            
            // Update the local state when the model changes
            if !isInitialSetup {
                updateACLimitFromModel()
            }
        }
    }
    
    private func updateACLimitFromModel() {
        if let vehicle = model.vehicle {
            // Display the configured AC current limit
            let configuredLimit = Int32(vehicle.vehicleState.chargingState.energyAcCurrentLimit)
            
            print("ACChargeLimitView: Updating from model - configuredLimit: \(configuredLimit), localState: \(acCurrentLimit), activeSession: \(vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit)A")
            
            if isInitialSetup {
                // Initial setup - use the vehicle's configured limit
                acCurrentLimit = configuredLimit
            } else {
                // After initial setup: only update if the vehicle value matches what we expect
                // OR if we're not in the middle of a request
                if !model.requestInProgress.contains(.acCurrentLimit) {
                    // Not making a request, use the vehicle's value
                    if configuredLimit != acCurrentLimit {
                        acCurrentLimit = configuredLimit
                    }
                }
                // Otherwise keep our optimistic update while request is in progress
            }
        }
    }
    
    private func adjustACLimit(by amount: Int32) {
        // Calculate the new target limit based on the current displayed limit
        let newTargetLimit = acCurrentLimit + amount
        
        // Clamp to reasonable range (1A to 80A)
        let clampedTargetLimit = max(1, min(80, newTargetLimit))
        
        if let vehicle = model.vehicle {
            print("ACChargeLimitView: Button pressed - amount: \(amount), current: \(acCurrentLimit), newTarget: \(newTargetLimit), clamped: \(clampedTargetLimit)")
            print("ACChargeLimitView: Charge state: \(vehicle.vehicleState.chargingState.chargeState), EA PnC status: \(vehicle.vehicleState.chargingState.eaPncStatus), Restart allowed: \(vehicle.vehicleState.chargingState.chargingSessionRestartAllowed)")
            print("ACChargeLimitView: GPS: \(vehicle.vehicleState.gps.location.latitude), \(vehicle.vehicleState.gps.location.longitude)")
        }
        
        // Skip if no change or during initial setup
        guard clampedTargetLimit != acCurrentLimit && !isInitialSetup else { 
            print("ACChargeLimitView: Skipping - no change or initial setup")
            return 
        }
        
        // Update local state immediately for responsive UI
        acCurrentLimit = clampedTargetLimit
        print("ACChargeLimitView: Updated local state to \(clampedTargetLimit)A")
        
        // Skip if request is already in progress to prevent multiple concurrent calls
        guard !model.requestInProgress.contains(.acCurrentLimit) else {
            print("ACChargeLimitView: Already setting AC limit, skipping")
            return
        }
        
        // Call API with the absolute target limit
        print("ACChargeLimitView: Calling model.setACCurrLimit(\(clampedTargetLimit))")
        model.setACCurrLimit(clampedTargetLimit)
    }
}

#Preview {
    ACChargeLimitView()
        .environment(DataModel())
        .padding()
}
