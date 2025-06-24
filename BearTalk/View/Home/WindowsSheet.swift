//
//  WindowsSheet.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

struct WindowControlButton: View {
    let systemImage: String
    let title: String
    let action: () -> Void
    let isDisabled: Bool
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: systemImage)
                    .font(.title)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isDisabled)
        .overlay {
            if isDisabled {
                ProgressView()
                    .padding()
            }
        }
    }
}

struct WindowsSheet: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    let isModelPresntation: Bool
    
    private func windowControl(for position: WindowPositionStatus, title: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(position.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 100, maxHeight: 60)
                .font(.title)
                .foregroundStyle(position != .fullyClosed ? .active : .accent)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text(position.positionTitle)
                .font(.caption2)
                .foregroundStyle(position != .fullyClosed ? .active : .accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var windowControlButtons: some View {
        let buttons = [
            (systemImage: "arrow.up.circle.fill", title: "Close All", action: { model.controlAllWindows(state: .autoUpAll) }),
            (systemImage: "arrow.down.circle.fill", title: "Open All", action: { model.controlAllWindows(state: .autoDownAll) }),
            (systemImage: "wind", title: "Vent All", action: { model.controlAllWindows(state: .ventAll) })
        ]
        
        return ViewThatFits {
            HStack(spacing: 12) {
                ForEach(buttons, id: \.title) { button in
                    WindowControlButton(
                        systemImage: button.systemImage,
                        title: button.title,
                        action: button.action,
                        isDisabled: model.requestInProgress.contains(.windows) || model.allFunctionsDisable
                    )
                }
            }
            
            VStack(spacing: 12) {
                ForEach(buttons, id: \.title) { button in
                    WindowControlButton(
                        systemImage: button.systemImage,
                        title: button.title,
                        action: button.action,
                        isDisabled: model.requestInProgress.contains(.windows) || model.allFunctionsDisable
                    )
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let windowPosition = model.windowPosition {
                        windowControlButtons
                            .padding(.horizontal)
                        
                        // Window Status Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            windowControl(for: windowPosition.leftFront, title: "Front Left", icon: "windowClosed")
                            windowControl(for: windowPosition.rightFront, title: "Front Right", icon: "windowClosed")
                            windowControl(for: windowPosition.leftRear, title: "Rear Left", icon: "windowClosed")
                            windowControl(for: windowPosition.rightRear, title: "Rear Right", icon: "windowClosed")
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 1)
                    } else {
                        ContentUnavailableView {
                            Label("No Window Data", systemImage: "window.vertical.closed")
                        } description: {
                            Text("Window position data is not available")
                        }
                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Windows")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isModelPresntation {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WindowsSheet(isModelPresntation: true)
        .environment(DataModel())
} 
