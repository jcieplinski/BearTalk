//
//  ControlButton.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

struct ControlButton: View {
    let controlType: ControlType
    
    @Binding var isActive: Bool
    
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
        ControlButton(controlType: .frunk, isActive: $isActive) { _ in }
        ControlButton(controlType: .trunk, isActive: $isActive) { _ in }
        ControlButton(controlType: .climateControl, isActive: $isActive) { _ in }
        ControlButton(controlType: .batteryPrecondition, isActive: $isActive) { _ in }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight:  .infinity)
    .background(.black)
}
