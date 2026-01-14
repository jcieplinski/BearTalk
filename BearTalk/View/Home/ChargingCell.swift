import SwiftUI

struct ChargingCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false
    
    var chargeLimit: String {
        if let vehicle = model.vehicle {
            return "\(Int(vehicle.vehicleState.chargingState.chargeLimitPercent))%"
        }
        return "80%"
    }
    
    var body: some View {
        Group {
            if isWideMode {
                Button {
                    showSheet = true
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    ChargingView()
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                ChargingView()
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            if #available(iOS 26.0, *) {
                                Button(role: .confirm) {
                                    showSheet = false
                                }
                            } else {
                                Button("Done") {
                                    showSheet = false
                                }
                            }
                        }
                    }
            }
            .presentationSizing(.page)
        }
    }
    
    private var cellContent: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Charging")
                    .font(.headline)
                
                Spacer()
            }
            
            if let vehicle = model.vehicle {
                ChargingStatusView(
                    chargingState: vehicle.vehicleState.chargingState.chargeState,
                    sessionMinutesRemaining: vehicle.vehicleState.chargingState.sessionMinutesRemaining
                )
                
                // Stop Charging Button - only show when actively charging
                if vehicle.vehicleState.chargingState.chargeState == .charging {
                    Button {
                        model.stopCharging()
                    } label: {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                                .font(.title3)
                            
                            Text("Stop Charging")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(.alertRed)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .disabled(model.requestInProgress.contains(.chargeLimit) || model.allFunctionsDisable)
                }
            }
            
            ViewThatFits {
                HStack {
                    Text("Current: \(model.chargePercentage)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Charge Limit: \(chargeLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                VStack {
                    HStack {
                        Text("Current: \(model.chargePercentage)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Charge Limit: \(chargeLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        ChargingCell(isWideMode: false)
            .environment(DataModel())
            .padding()
    }
} 
