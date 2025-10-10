import SwiftUI

struct MaintenanceView: View {
    @Environment(DataModel.self) var model
    
    // Convert bar to user's preferred pressure unit
    private func convertBarToPreferredUnit(_ bar: Double) -> Double {
        let currentUnit = UnitConverter.currentTirePressureUnit
        let psi = bar * 14.5038
        return UnitConverter.convertTirePressure(psi, from: .psi, to: currentUnit)
    }
    
    private func formatPressure(_ pressure: Double) -> String {
        let currentUnit = UnitConverter.currentTirePressureUnit
        return UnitConverter.formatTirePressure(pressure, unit: currentUnit)
    }

    let cardWidth: CGFloat = 130

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
                        
                        ZStack {
                            // Car image in the center
                            CarSnapshotView()
                                .frame(width: 200, height: 200)

                            // Tire pressure cards positioned around the car
                            VStack {
                                // Top row: Front tires
                                HStack {
                                    Spacer()
                                    TirePressureCard(
                                        title: "Front Left",
                                        pressure: formatPressure(convertBarToPreferredUnit(chassisState.frontLeftTirePressureBar)),
                                        hasWarning: chassisState.hardWarnLeftFront == .warningOn || chassisState.softWarnLeftFront == .warningOn
                                    )
                                    .frame(width: cardWidth)

                                    Spacer()
                                    
                                    TirePressureCard(
                                        title: "Front Right",
                                        pressure: formatPressure(convertBarToPreferredUnit(chassisState.frontRightTirePressureBar)),
                                        hasWarning: chassisState.hardWarnRightFront == .warningOn || chassisState.softWarnRightFront == .warningOn
                                    )
                                    .frame(width: cardWidth)

                                    Spacer()
                                }
                                
                                Spacer()
                                
                                // Bottom row: Rear tires
                                HStack {
                                    Spacer()
                                    TirePressureCard(
                                        title: "Rear Left",
                                        pressure: formatPressure(convertBarToPreferredUnit(chassisState.rearLeftTirePressureBar)),
                                        hasWarning: chassisState.hardWarnLeftRear == .warningOn || chassisState.softWarnLeftRear == .warningOn
                                    )
                                    .frame(width: cardWidth)

                                    Spacer()
                                    
                                    TirePressureCard(
                                        title: "Rear Right",
                                        pressure: formatPressure(convertBarToPreferredUnit(chassisState.rearRightTirePressureBar)),
                                        hasWarning: chassisState.hardWarnRightRear == .warningOn || chassisState.softWarnRightRear == .warningOn
                                    )
                                    .frame(width: cardWidth)

                                    Spacer()
                                }
                            }
                            .frame(width: 300, height: 300)
                        }
                    } else {
                        Text("No vehicle data available")
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
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
                .dynamicTypeSize(...DynamicTypeSize.xLarge)

            Text(pressure)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(hasWarning ? .red : .primary)
                .dynamicTypeSize(...DynamicTypeSize.xLarge)

            if hasWarning {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .dynamicTypeSize(...DynamicTypeSize.xLarge)
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
