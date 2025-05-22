//
//  ControlButton.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

struct ControlButton: View {
    @Environment(DataModel.self) var model
    let controlType: ControlType
    
    var isActive: Bool {
        switch controlType {
        case .wake:
            return false
        case .doorLocks:
            return model.lockState == .locked
        case .frunk:
            return model.frunkClosureState == .open
        case .trunk:
            return model.trunkClosureState == .open
        case .chargePort:
            return model.chargePortClosureState == .open
        case .climateControl:
            guard let climatePowerState = model.climatePowerState else {
                return false
            }
            
            return climatePowerState.isOn
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
        case .batteryPrecondition:
            return model.batteryPreConditionState == .batteryPreconOn
        }
    }
    
    let action: (ControlType) -> Void
    
    var body: some View {
        ZStack {
            Button {
                action(controlType)
            } label: {
                ControlButtonCore(controlType: controlType, isActive: isActive)
            }
            
            if model.requestInProgress.contains(controlType) {
                ProgressView()
                    .controlSize(.large)
                    .foregroundStyle(.active)
            }
        }
    }
}

#Preview {
    @Previewable @State var isActive: Bool = false
    
    HStack {
        ControlButton(controlType: .frunk) { _ in }
        ControlButton(controlType: .trunk) { _ in }
        ControlButton(controlType: .climateControl) { _ in }
        ControlButton(controlType: .batteryPrecondition) { _ in }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight:  .infinity)
    .background(.black)
}
