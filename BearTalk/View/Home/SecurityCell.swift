import SwiftUI

struct SecurityCell: View {
    @Environment(DataModel.self) var model
    
    var alarmStatus: String {
        if let vehicle = model.vehicle {
            switch vehicle.vehicleState.alarmState.alarmMode {
            case .on:
                return "On"
            case .off:
                return "Off"
            case .silent:
                return "Silent"
            case .unknown, .UNRECOGNIZED:
                return "Unknown"
            }
        }
        return "Unknown"
    }
    
    var body: some View {
        NavigationLink {
            AlarmView()
        } label: {
            VStack(spacing: 16) {
                HStack {
                    Text("Security")
                        .font(.headline)
                    
                    Spacer()
                }
                
                HStack {
                    Text("Shock and Tilt Alarm: \(alarmStatus)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
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
        SecurityCell()
            .environment(DataModel())
            .padding()
    }
} 