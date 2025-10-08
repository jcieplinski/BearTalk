import SwiftUI

struct ChargingCell: View {
    @Environment(DataModel.self) var model
    
    var chargeLimit: String {
        if let vehicle = model.vehicle {
            return "\(Int(vehicle.vehicleState.chargingState.chargeLimitPercent))%"
        }
        return "80%"
    }
    
    var body: some View {
        NavigationLink {
            ChargingView()
        } label: {
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
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ChargingCell()
            .environment(DataModel())
            .padding()
    }
} 
