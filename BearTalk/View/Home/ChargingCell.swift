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
                
                HStack {
                    Text("Current: \(model.chargePercentage)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Charge Limit: \(chargeLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
