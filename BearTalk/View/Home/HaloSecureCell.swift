import SwiftUI

struct HaloSecureCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false

    private var statusText: String {
        guard let alarmMode = model.vehicle?.vehicleState.alarmState.alarmMode,
              let option = AntiTheftOption(alarmMode: alarmMode) else {
            return "Unknown"
        }
        return option.title
    }

    var body: some View {
        Group {
            if isWideMode {
                Button {
                    showSheet = true
                } label: {
                    cellLabel
                }
                .buttonStyle(.plain)
            } else {
                NavigationLink {
                    HaloSecureView()
                } label: {
                    cellLabel
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                HaloSecureView()
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

    private var cellLabel: some View {
        HaloSecureCellLabel(statusText: statusText)
    }
}

#Preview {
    NavigationStack {
        HaloSecureCell(isWideMode: false)
            .environment(DataModel())
            .padding()
    }
}
