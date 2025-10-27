import SwiftUI

struct ClimateControlsCell: View {
    @Environment(DataModel.self) var model
    let isWideMode: Bool
    @State private var showSheet = false
    
    var powerIsOn: Bool {
        guard let climatePowerState = model.climatePowerState else { return false }
        return climatePowerState.isOn
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
                    ClimateControlView()
                } label: {
                    cellContent
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                ClimateControlView()
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
                .disabled(model.requestInProgress.contains(.climateControl) || model.allFunctionsDisable)
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
}

#Preview {
    NavigationStack {
        ClimateControlsCell(isWideMode: false)
            .environment(DataModel())
            .padding()
    }
} 
