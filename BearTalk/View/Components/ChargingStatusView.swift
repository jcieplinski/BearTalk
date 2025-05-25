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
                Label("Charging in Progress", systemImage: "bolt.fill")
                    .foregroundStyle(.green)
                    .fixedSize(horizontal: false, vertical: true)
                
                if sessionMinutesRemaining > 0 {
                    Text(formatTimeRemaining(sessionMinutesRemaining))
                        .font(.subheadline)
                        .fixedSize(horizontal: false, vertical: true)
                        .foregroundStyle(.secondary)
                }
            case .notConnected:
                Label("Not Connected", systemImage: "bolt.slash")
                    .foregroundStyle(.secondary)
            case .cableConnected:
                Label("Cable Connected", systemImage: "bolt")
                    .foregroundStyle(.yellow)
            case .establishingSession, .authorizingPnc, .authorizingExternal, .authorized, .chargerPreparation:
                Label("Preparing to Charge", systemImage: "bolt.circle")
                    .foregroundStyle(.yellow)
            case .chargingEndOk:
                Label("Charging Complete", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .chargingStopped:
                Label("Charging Stopped", systemImage: "stop.circle.fill")
                    .foregroundStyle(.red)
            case .evseMalfunction:
                Label("Charging Error", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            case .discharging:
                Label("Discharging", systemImage: "arrow.down.circle.fill")
                    .foregroundStyle(.orange)
            case .dischargingCompleted:
                Label("Discharging Complete", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            case .dischargingStopped:
                Label("Discharging Stopped", systemImage: "stop.circle.fill")
                    .foregroundStyle(.red)
            case .dischargingFault:
                Label("Discharging Error", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
            case .dischargingUnavailable:
                Label("Discharging Unavailable", systemImage: "bolt.slash.fill")
                    .foregroundStyle(.secondary)
            case .unknown, .UNRECOGNIZED:
                Label("Unknown Status", systemImage: "questionmark.circle")
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
