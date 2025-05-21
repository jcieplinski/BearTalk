//
//  ControlGrid.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI

struct ControlGrid: View {
    @Environment(DataModel.self) var model
    @AppStorage(DefaultsKey.controlsFavorites) var controlsFavorites: String = [ControlType.doorLocks.rawValue,ControlType.frunk.rawValue,ControlType.trunk.rawValue,ControlType.chargePort.rawValue].joined(separator: ",")
    
    @State private var isActive: Bool = false
    @State private var selectedControls: [ControlType] = []
    @State private var nonSelectedControls: [ControlType] = []
    @State private var showingAvailableControls: Bool = false
    @State private var draggedItem: ControlType?
    
    var body: some View {
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
                        isActive: $isActive,
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
            }
            .padding()
            
            if showingAvailableControls {
                VStack {
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundStyle(.gray)
                            .padding()
                        
                        Button {
                            showingAvailableControls = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.primary)
                        }
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
                                isActive: $isActive,
                                action: { _ in }
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
                    }
                    .padding()
                }
            } else {
                Button {
                    showingAvailableControls = true
                } label: {
                    Label("Edit", systemImage: "pencil.circle")
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                .buttonStyle(.bordered)
                .tint(.active)
            }
        }
        .animation(.bouncy, value: showingAvailableControls)
        .onAppear {
            selectedControls = controlsFavorites.split(separator: ",").compactMap({ ControlType(rawValue: String($0)) })
            
            nonSelectedControls = ControlType.allCases.filter({ !selectedControls.contains($0) })
        }
        .onChange(of: selectedControls) { oldValue, newValue in
            controlsFavorites = selectedControls.map(\.rawValue).joined(separator: ",")
        }
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
