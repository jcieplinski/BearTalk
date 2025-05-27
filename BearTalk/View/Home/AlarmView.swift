import SwiftUI

struct AlarmView: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    var alarmMode: AlarmMode {
        model.vehicle?.vehicleState.alarmState.alarmMode ?? .unknown
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 16) {
                    HStack {
                        Text("Shock and Tilt Alarm")
                            .font(.headline)
                        
                        Spacer()
                        
                        Toggle("", isOn: Binding(
                            get: { alarmMode == .on },
                            set: { newValue in
                                Task {
                                    await model.setShockAndTilt(enabled: newValue)
                                }
                            }
                        ))
                        .labelsHidden()
                        .tint(.active)
                        .disabled(model.requestInProgress.contains(.alarm))
                    }
                    
                    if alarmMode != .on {
                        HStack {
                            Text("Disabled Temporarily until you re-enter the vehicle")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    if model.requestInProgress.contains(.alarm) {
                        ProgressView()
                            .controlSize(.large)
                            .foregroundStyle(.active)
                            .transition(.scale)
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .animation(.default, value: model.requestInProgress)
            .padding()
        }
        .scrollBounceBehavior(.basedOnSize)
        .navigationTitle("Security")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        AlarmView()
            .environment(DataModel())
    }
} 
