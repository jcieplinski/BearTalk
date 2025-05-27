//
//  ControlGrid.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI

struct ControlGrid: View {
    @Environment(DataModel.self) var model
    @AppStorage(DefaultsKey.controlsFavorites, store: .appGroup) var controlsFavorites: String = [ControlType.doorLocks.rawValue,ControlType.frunk.rawValue,ControlType.trunk.rawValue,ControlType.chargePort.rawValue].joined(separator: ",")
    
    @State private var selectedControls: [ControlType] = []
    @State private var nonSelectedControls: [ControlType] = []
    @State private var draggedItem: ControlType?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    alignment: .center,
                    spacing: 16
                ) {
                    ForEach(selectedControls) { control in
                        ControlButton(
                            controlType: control,
                            action: model.handleControlAction
                        )
                        .draggable(control) {
                            Rectangle()
                                .foregroundStyle(.ultraThinMaterial)
                                .frame(width: 1, height: 1)
                            .onAppear {
                                draggedItem = control
                            }
                        }
                        .dropDestination(for: ControlType.self) { items, location in
                            draggedItem = nil
                            return false
                        } isTargeted: { status in
                            if let draggedItem, status, draggedItem != control {
                                if let sourceIndex = selectedControls.firstIndex(of: draggedItem),
                                    let destinationIndex = selectedControls.firstIndex(of: control) {
                                    withAnimation(.bouncy) {
                                        let sourceControl = selectedControls.remove(at: sourceIndex)
                                        selectedControls.insert(sourceControl, at: destinationIndex)
                                    }
                                } else if let sourceIndex = nonSelectedControls.firstIndex(of: draggedItem),
                                          let destinationIndex = selectedControls.firstIndex(of: control) {
                                    withAnimation(.bouncy) {
                                        let sourceControl = nonSelectedControls.remove(at: sourceIndex)
                                        selectedControls.insert(sourceControl, at: destinationIndex)
                                    }
                                }
                            }
                        }
                    }
                    
                    if draggedItem != nil && model.showingAvailableControls {
                        RoundedRectangle(cornerRadius: 13)
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundStyle(.thinMaterial)
                            .opacity(0.3)
                            .dropDestination(for: ControlType.self) { items, location in
                                draggedItem = nil
                                return false
                            } isTargeted: { status in
                                if let draggedItem, status {
                                    if let sourceIndex = selectedControls.firstIndex(of: draggedItem) {
                                        withAnimation(.bouncy) {
                                            let sourceControl = selectedControls.remove(at: sourceIndex)
                                            selectedControls.append(sourceControl)
                                        }
                                    } else if let sourceIndex = nonSelectedControls.firstIndex(of: draggedItem) {
                                        withAnimation(.bouncy) {
                                            let sourceControl = nonSelectedControls.remove(at: sourceIndex)
                                            selectedControls.append(sourceControl)
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding()
                
                Button {
                    withAnimation(.spring(duration: 0.3)) {
                        model.showingAvailableControls.toggle()
                    }
                } label: {
                    Label("open", systemImage: "chevron.forward.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title)
                        .rotationEffect(model.showingAvailableControls ? .degrees(90) : .degrees(0))
                }
                .tint(.secondary)
            }
            
            if model.showingAvailableControls {
                VStack {
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray)
                            .padding()
                    }
                    
                    Text("Drag buttons above to add them to your favorites. Drag items below to remove from favorites.")
                        .font(.caption)
                        .padding(.horizontal)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ],
                        alignment: .center,
                        spacing: 16
                    ) {
                        ForEach(nonSelectedControls) { control in
                            ControlButton(
                                controlType: control,
                                action: model.handleControlAction
                            )
                            .draggable(control) {
                                Rectangle()
                                    .foregroundStyle(.ultraThinMaterial)
                                    .frame(width: 1, height: 1)
                                    .onAppear {
                                        draggedItem = control
                                    }
                            }
                            .dropDestination(for: ControlType.self) { items, location in
                                draggedItem = nil
                                return false
                            } isTargeted: { status in
                                if let draggedItem, status, draggedItem != control {
                                    if let sourceIndex = nonSelectedControls.firstIndex(of: draggedItem),
                                       let destinationIndex = nonSelectedControls.firstIndex(of: control) {
                                        withAnimation(.bouncy) {
                                            let sourceControl = nonSelectedControls.remove(at: sourceIndex)
                                            nonSelectedControls.insert(sourceControl, at: destinationIndex)
                                        }
                                    } else if let sourceIndex = selectedControls.firstIndex(of: draggedItem),
                                              let destinationIndex = nonSelectedControls.firstIndex(of: control) {
                                        withAnimation(.bouncy) {
                                            let sourceControl = selectedControls.remove(at: sourceIndex)
                                            nonSelectedControls.insert(sourceControl, at: destinationIndex)
                                        }
                                    }
                                }
                            }
                        }
                        
                        if draggedItem != nil && model.showingAvailableControls {
                            RoundedRectangle(cornerRadius: 13)
                                .aspectRatio(1, contentMode: .fit)
                                .foregroundStyle(.thinMaterial)
                                .frame(minHeight: 44)
                                .opacity(0.3)
                                .dropDestination(for: ControlType.self) { items, location in
                                    draggedItem = nil
                                    return false
                                } isTargeted: { status in
                                    if let draggedItem, status {
                                        if let sourceIndex = nonSelectedControls.firstIndex(of: draggedItem) {
                                            withAnimation(.bouncy) {
                                                let sourceControl = nonSelectedControls.remove(at: sourceIndex)
                                                nonSelectedControls.append(sourceControl)
                                            }
                                        } else if let sourceIndex = selectedControls.firstIndex(of: draggedItem) {
                                            withAnimation(.bouncy) {
                                                let sourceControl = selectedControls.remove(at: sourceIndex)
                                                nonSelectedControls.append(sourceControl)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .bottom).combined(with: .opacity)
                ))
            }
        }
        .animation(.spring(duration: 0.3), value: model.showingAvailableControls)
        .onAppear {
            selectedControls = controlsFavorites.split(separator: ",").compactMap({ ControlType(rawValue: String($0)) })
            
            switch model.vehicle?.vehicleConfig.model {
            case .unknown, .air:
                nonSelectedControls = ControlType.allCases.filter({ !selectedControls.contains($0) })
            case .gravity:
                nonSelectedControls = ControlType.allCasesGravity.filter({ !selectedControls.contains($0) })
            case .UNRECOGNIZED:
                break
            case nil:
                break
            }
        }
        .onChange(of: selectedControls) { oldValue, newValue in
            controlsFavorites = selectedControls.map(\.rawValue).joined(separator: ",")
        }
        .animation(.bouncy, value: draggedItem)
    }
}

#Preview {
    VStack {
        ControlGrid()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
    .padding()
}
