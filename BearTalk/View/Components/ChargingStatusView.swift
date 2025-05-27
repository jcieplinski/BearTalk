import SwiftUI

struct ChargingStatusView: View {
    let chargingState: ChargeState
    let sessionMinutesRemaining: UInt32
    
    private func formatTimeRemaining(_ minutes: UInt32) -> String {
        if minutes >= 60 {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "\(hours) hour\(hours == 1 ? "" : "s") remaining"
            } else {
                return "\(hours) hour\(hours == 1 ? "" : "s") \(remainingMinutes) minute\(remainingMinutes == 1 ? "" : "s") remaining"
            }
        } else {
            return "\(minutes) minute\(minutes == 1 ? "" : "s") remaining"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            switch chargingState {
            case .charging:
                Label(chargingState.title, systemImage: "bolt.fill")
                    .foregroundStyle(.green)
                    .fixedSize(horizontal: false, vertical: true)
                
                if sessionMinutesRemaining > 0 {
                    Text(formatTimeRemaining(sessionMinutesRemaining))
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.secondary)
                }
            default:
                Label(chargingState.title, systemImage: "bolt.slash")
                    .foregroundStyle(.secondary)
            }
        }
        .font(.headline)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 20) {
        ChargingStatusView(chargingState: .charging, sessionMinutesRemaining: 45)
        ChargingStatusView(chargingState: .charging, sessionMinutesRemaining: 60)
        ChargingStatusView(chargingState: .charging, sessionMinutesRemaining: 90)
        ChargingStatusView(chargingState: .charging, sessionMinutesRemaining: 120)
        ChargingStatusView(chargingState: .charging, sessionMinutesRemaining: 1)
        ChargingStatusView(chargingState: .notConnected, sessionMinutesRemaining: 0)
        ChargingStatusView(chargingState: .cableConnected, sessionMinutesRemaining: 0)
        ChargingStatusView(chargingState: .chargingEndOk, sessionMinutesRemaining: 0)
        ChargingStatusView(chargingState: .evseMalfunction, sessionMinutesRemaining: 0)
    }
    .padding()
} 
