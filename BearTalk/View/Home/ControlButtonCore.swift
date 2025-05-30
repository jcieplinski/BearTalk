//
//  ControlButtonCore.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftUI

struct ControlButtonCore: View {
    @Environment(DataModel.self) var model
    
    let controlType: ControlType
    let isActive: Bool
    
    var body: some View {
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
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .foregroundStyle(isActive ? .active.opacity(0.2) : .clear)
                
                RoundedRectangle(cornerRadius: 13)
                    .stroke(style: StrokeStyle(lineWidth: 1))
            }
        )
        .tint(isActive ? .active : .inactive)
        .disabled(model.requestInProgress.contains(controlType))
    }
}
