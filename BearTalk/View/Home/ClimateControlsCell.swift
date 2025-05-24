import SwiftUI

struct ClimateControlsCell: View {
    @Environment(DataModel.self) var model
    
    var powerIsOn: Bool {
        guard let climatePowerState = model.climatePowerState else { return false }
        return climatePowerState.isOn
    }
    
    var body: some View {
        NavigationLink {
            ClimateControlView()
        } label: {
            VStack(spacing: 8) {
                HStack(alignment: .top) {
                    Text("Climate")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button {
                        model.toggleClimateControl()
                    } label: {
                        ZStack {
                            Image(systemName: powerIsOn ? "power.circle.fill" : "power.circle")
                                .font(.largeTitle)
                                .fontWeight(.thin)
                                .foregroundStyle(powerIsOn ? .active : .inactive)
                            
                            if model.requestInProgress.contains(.climateControl) {
                                ProgressView()
                                    .controlSize(.large)
                                    .foregroundStyle(.active)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(model.requestInProgress.contains(.climateControl))
                }
                
                HStack {
                    Text(powerIsOn ? "Target Temp: \(Int(model.selectedTemperature))°" : "Cabin Temp: \(model.exteriorTemp)")
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
        ClimateControlsCell()
            .environment(DataModel())
            .padding()
    }
} 
