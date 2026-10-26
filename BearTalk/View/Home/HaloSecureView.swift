import SwiftUI

struct HaloSecureView: View {
    @Environment(DataModel.self) var model

    private var selectedOption: AntiTheftOption? {
        guard let alarmMode = model.vehicle?.vehicleState.alarmState.alarmMode else {
            return nil
        }
        return AntiTheftOption(alarmMode: alarmMode)
    }

    private var controlsDisabled: Bool {
        model.requestInProgress.contains(.alarm) || model.allFunctionsDisable
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Anti-Theft Protection")
                        .font(.headline)

                    ForEach(AntiTheftOption.allCases) { option in
                        AntiTheftOptionRow(
                            option: option,
                            isSelected: selectedOption == option,
                            isDisabled: controlsDisabled
                        ) {
                            select(option)
                        }
                    }

                    if selectedOption == .off {
                        Text("Turns back on the next time you get in the car.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if model.requestInProgress.contains(.alarm) {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.active)
                            .frame(maxWidth: .infinity)
                            .transition(.scale)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .animation(.default, value: model.requestInProgress)
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Halo Secure")
        .navigationBarTitleDisplayMode(.large)
    }

    private func select(_ option: AntiTheftOption) {
        guard selectedOption != option else { return }

        Task {
            await model.setShockAndTilt(mode: option.alarmMode)
        }
    }
}

#Preview {
    NavigationStack {
        HaloSecureView()
            .environment(DataModel())
    }
}
