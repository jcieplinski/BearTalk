import SwiftUI

struct SecurityCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false
    
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
                    AlarmView()
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                AlarmView()
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
}

#Preview {
    NavigationStack {
        SecurityCell(isWideMode: false)
            .environment(DataModel())
            .padding()
    }
}
