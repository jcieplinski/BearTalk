//
//  WindowsSheet.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import SwiftUI

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
            
            Text(position.positionTitle)
                .font(.caption2)
                .foregroundStyle(position != .fullyClosed ? .active : .accent)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                if let windowPosition = model.windowPosition {
                    HStack(spacing: 12) {
                        Button {
                            model.controlAllWindows(state: .autoUpAll)
                        } label: {
                            VStack {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.title)
                                Text("Close All")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(model.requestInProgress.contains(.windows))
                        .overlay {
                            if model.requestInProgress.contains(.windows) {
                                ProgressView()
                                    .padding()
                            }
                        }
                        
                        Button {
                            model.controlAllWindows(state: .autoDownAll)
                        } label: {
                            VStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.title)
                                Text("Open All")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(model.requestInProgress.contains(.windows))
                        .overlay {
                            if model.requestInProgress.contains(.windows) {
                                ProgressView()
                                    .padding()
                            }
                        }
                        
                        Button {
                            model.controlAllWindows(state: .ventAll)
                        } label: {
                            VStack {
                                Image(systemName: "wind")
                                    .font(.title)
                                Text("Vent All")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(model.requestInProgress.contains(.windows))
                        .overlay {
                            if model.requestInProgress.contains(.windows) {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
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
