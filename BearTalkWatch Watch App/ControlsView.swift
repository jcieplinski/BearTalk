//
//  ControlsView.swift
//  BearTalkWatch Watch App
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

struct ControlsView: View {
    @Bindable var model: VehicleViewModel
    @AppStorage("watchControlGrid", store: .appGroup) private var controlGrid: String = ""
    @State private var showingConfiguration = false
    
    // Default 3x3 grid based on widget defaults plus one more
    private let defaultControls: [ControlType] = [
        .doorLocks, .chargePort, .frunk,
        .trunk, .lights, .defrost,
        .climateControl, .maxAC, .horn
    ]
    
    private var gridControls: [ControlType] {
        if controlGrid.isEmpty {
            return defaultControls
        }
        
        let savedControls = controlGrid.split(separator: ",").compactMap { ControlType(rawValue: String($0)) }
        // Ensure we always have exactly 9 controls
        var result = savedControls
        while result.count < 9 {
            result.append(defaultControls[result.count])
        }
        return Array(result.prefix(9))
    }
    
    var body: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ],
            spacing: 4
        ) {
            ForEach(0..<9, id: \.self) { index in
                if index < gridControls.count {
                    WatchControlButton(
                        controlType: gridControls[index],
                        isActive: isActive(for: gridControls[index]),
                        action: { handleControlAction(gridControls[index]) }
                    )
                }
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingConfiguration = true
                } label: {
                    Label("Configure", systemImage: "gear")
                        .labelStyle(.iconOnly)
                        .foregroundStyle(.white)
                }
            }
        }
        .sheet(isPresented: $showingConfiguration) {
            ControlConfigurationView(
                currentControls: gridControls,
                onSave: { newControls in
                    controlGrid = newControls.map(\.rawValue).joined(separator: ",")
                    showingConfiguration = false
                }
            )
        }
    }
    
    private func isActive(for control: ControlType) -> Bool {
        switch control {
        case .wake:
            return false
        case .doorLocks:
            return model.lockState == .locked
        case .frunk:
            return model.frunkClosureState != .closed
        case .trunk:
            return model.trunkClosureState != .closed
        case .chargePort:
            return model.chargePortClosureState != .closed
        case .climateControl:
            return model.climatePowerState == .hvacOn
        case .maxAC:
            return model.maxACState == .on
        case .seatClimate:
            return model.seatClimateState?.isOn ?? false
        case .steeringWheelClimate:
            return model.steeringHeaterStatus == .on
        case .defrost:
            return model.defrostState == .defrostOn
        case .horn:
            return false
        case .lights:
            return model.lightsState == .on
        case .hazards:
            return false
        case .windows:
            return model.windowPosition?.isOpen ?? false
        case .batteryPrecondition:
            return model.batteryPreConditionState == .batteryPreconOn
        case .softwareUpdate:
            return false
        case .chargeLimit:
            return false
        case .driverSeatHeat:
            return false
        case .driverSeatVent:
            return false
        case .passengerSeatHeat:
            return false
        case .passengerSeatVent:
            return false
        case .rearLeftSeatHeat:
            return false
        case .rearCenterSeatHeat:
            return false
        case .rearRightSeatHeat:
            return false
        case .alarm:
            return false
        }
    }
    
    private func handleControlAction(_ control: ControlType) {
        // Send control action to phone app via WatchConnectivity
        WatchConnectivityManager.shared.sendControlAction(control)
    }
}

struct WatchControlButton: View {
    let controlType: ControlType
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(isActive ? Color.active.opacity(0.2) : Color.clear)
                    .stroke(isActive ? .active : .accentColor, lineWidth: 1)
                
                Image(isActive ? controlType.onImage : controlType.offImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(8)
                    .foregroundStyle(isActive ? .active : .accentColor)
            }
        }
        .buttonStyle(.plain)
    }
}

struct ControlConfigurationView: View {
    let currentControls: [ControlType]
    let onSave: ([ControlType]) -> Void
    
    @State private var selectedControls: [ControlType]
    @Environment(\.dismiss) private var dismiss
    
    init(currentControls: [ControlType], onSave: @escaping ([ControlType]) -> Void) {
        self.currentControls = currentControls
        self.onSave = onSave
        self._selectedControls = State(initialValue: currentControls)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<9, id: \.self) { index in
                    NavigationLink {
                        ControlPickerView(
                            selectedControl: $selectedControls[index],
                            title: "Button \(index + 1)"
                        )
                    } label: {
                        HStack {
                            Text("\(index + 1)")
                            Image(selectedControls[index].offImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundStyle(.accent)
                            
                            Text(selectedControls[index].title)
                                .font(.body)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Configure Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        onSave(selectedControls)
                    }
                }
            }
        }
    }
}

struct ControlPickerView: View {
    @Binding var selectedControl: ControlType
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(Array(ControlType.allCases.enumerated()), id: \.element) { _, controlType in
                Button {
                    selectedControl = controlType
                    dismiss()
                } label: {
                    HStack {
                        Image(controlType.offImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.accent)
                        
                        Text(controlType.title)
                            .font(.body)
                        
                        Spacer()
                        
                        if controlType == selectedControl {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accent)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ControlsView(model: VehicleViewModel(container: try! ModelContainer(for: VehicleIdentifier.self)))
} 
