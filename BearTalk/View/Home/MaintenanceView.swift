import SwiftUI

struct MaintenanceView: View {
    @Environment(DataModel.self) var model
    
    // Convert bar to PSI (1 bar = 14.5038 PSI)
    private func barToPSI(_ bar: Double) -> Double {
        return bar * 14.5038
    }
    
    private func formatPSI(_ psi: Double) -> String {
        return String(format: "%.1f", psi)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Tire Pressure Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tire Pressure")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if let vehicle = model.vehicle {
                        let chassisState = vehicle.vehicleState.chassisState
                        
                        VStack(spacing: 12) {
                            // Front row: Front Left and Front Right
                            HStack(spacing: 12) {
                                TirePressureCard(
                                    title: "Front Left",
                                    pressure: formatPSI(barToPSI(chassisState.frontLeftTirePressureBar)),
                                    hasWarning: chassisState.hardWarnLeftFront == .warningOn || chassisState.softWarnLeftFront == .warningOn
                                )
                                
                                TirePressureCard(
                                    title: "Front Right",
                                    pressure: formatPSI(barToPSI(chassisState.frontRightTirePressureBar)),
                                    hasWarning: chassisState.hardWarnRightFront == .warningOn || chassisState.softWarnRightFront == .warningOn
                                )
                            }
                            
                            // Rear row: Rear Left and Rear Right
                            HStack(spacing: 12) {
                                TirePressureCard(
                                    title: "Rear Left",
                                    pressure: formatPSI(barToPSI(chassisState.rearLeftTirePressureBar)),
                                    hasWarning: chassisState.hardWarnLeftRear == .warningOn || chassisState.softWarnLeftRear == .warningOn
                                )
                                
                                TirePressureCard(
                                    title: "Rear Right",
                                    pressure: formatPSI(barToPSI(chassisState.rearRightTirePressureBar)),
                                    hasWarning: chassisState.hardWarnRightRear == .warningOn || chassisState.softWarnRightRear == .warningOn
                                )
                            }
                        }
                    } else {
                        Text("No vehicle data available")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Maintenance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TirePressureCard: View {
    let title: String
    let pressure: String
    let hasWarning: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Text("\(pressure) PSI")
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(hasWarning ? .red : .primary)
            
            if hasWarning {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(hasWarning ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        MaintenanceView()
            .environment(DataModel())
    }
}
