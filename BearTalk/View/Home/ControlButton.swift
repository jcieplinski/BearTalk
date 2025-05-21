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
            return model.climatePowerState == .hvacKeepTemp || model.climatePowerState == .hvacOn
        case .maxAC:
            return model.maxACState == .on
        case .seatClimate:
            return model.seatClimateState?.isOn ?? false
        case .steeringWheelClimate:
            return model.steeringWheelClimateState == .on
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
        Button {
            action(controlType)
        } label: {
            Label {
                Text(controlType.title)
            } icon: {
                Image(isActive ? controlType.onImage : controlType.offImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 44, maxHeight: 44)
            }
            .labelStyle(.iconOnly)
            
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 13)
                    .stroke(style: StrokeStyle(lineWidth: 2))
            )
        }
        .tint(isActive ? .active : .inactive)
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
