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
                    adjustACLimit(by: -1)
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
                    adjustACLimit(by: 1)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.active)
                }
                .buttonStyle(.plain)
                .disabled(model.requestInProgress.contains(.acCurrentLimit) || model.allFunctionsDisable)
            }
            
            // Show current AC current if there's an active charging session
            if let vehicle = model.vehicle,
               vehicle.vehicleState.chargingState.chargeState == .charging,
               vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit > 0 {
                HStack {
                    Text("Current AC: \(vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit)A")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                // Debug info
                HStack {
                    Text("Debug - Base: \(vehicle.vehicleState.chargingState.energyAcCurrentLimit)A, Delta: \(vehicle.vehicleState.mobileAppReqStatus.acCurrentLimitReq)A")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
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
            // The acCurrentLimitReq is a delta/change, not the absolute limit
            // We need to add it to the current energyAcCurrentLimit to get the target limit
            let currentLimit = Int32(vehicle.vehicleState.chargingState.energyAcCurrentLimit)
            let requestedChange = vehicle.vehicleState.mobileAppReqStatus.acCurrentLimitReq
            let targetLimit = currentLimit + requestedChange
            
            print("ACChargeLimitView: Updating from model - currentLimit: \(currentLimit), requestedChange: \(requestedChange), targetLimit: \(targetLimit), activeSessionAcCurrentLimit: \(vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit)")
            
            // Display the target limit (current + requested change)
            acCurrentLimit = targetLimit
        }
    }
    
    private func adjustACLimit(by amount: Int32) {
        // Calculate the new target limit based on the current displayed limit
        let newTargetLimit = acCurrentLimit + amount
        
        // Clamp to reasonable range (1A to 80A)
        let clampedTargetLimit = max(1, min(80, newTargetLimit))
        
        print("ACChargeLimitView: Button pressed - amount: \(amount), current: \(acCurrentLimit), newTarget: \(newTargetLimit), clamped: \(clampedTargetLimit), isInitialSetup: \(isInitialSetup)")
        
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
