//
//  WidgetControlButtonCore.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/30/25.
//

import SwiftUI
import AppIntents

struct WidgetControlButton: View {
    let controlType: ControlType
    let isActive: Bool
    let intent: any AppIntent
    let isDisabled: Bool
    
    var body: some View {
        Button(intent: intent) {
            WidgetControlButtonCore(
                controlType: controlType,
                isActive: isActive,
                isDisabled: isDisabled
            )
        }
        .buttonStyle(.plain)
        .tint(isActive ? .active : .accentColor)
        .frame(maxWidth: .infinity)
        .disabled(isDisabled)
    }
}

struct WidgetControlButtonCore: View {
    let controlType: ControlType
    let isActive: Bool
    let isDisabled: Bool
    
    var body: some View {
        Label {
            Text(controlType.title)
        } icon: {
            Image(isActive ? controlType.onImage : controlType.offImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 33, maxHeight: 33)
                .foregroundStyle(isDisabled ? .gray : (isActive ? .active : .inactive))
        }
        .labelStyle(.iconOnly)
        
        .padding(4)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 13)
                    .foregroundStyle(isActive ? .active.opacity(0.2) : .clear)
                
                RoundedRectangle(cornerRadius: 13)
                    .stroke(isDisabled ? .gray : (isActive ? .active : .clear), style: StrokeStyle(lineWidth: 1))
            }
        )
        .padding(4)
        .tint(isDisabled ? .gray : (isActive ? .active : .inactive))
        .opacity(isDisabled ? 0.5 : 1.0)
    }
}
