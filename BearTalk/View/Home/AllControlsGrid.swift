//
//  AllControlsGrid.swift
//  BearTalk
//
//  Created on 1/7/26.
//

import SwiftUI

struct AllControlsGrid: View {
    @Environment(DataModel.self) var model
    @AppStorage(DefaultsKey.allControlsOrder, store: .appGroup) var allControlsOrder: String = ""
    
    @State private var controls: [ControlType] = []
    @State private var draggedItem: ControlType?
    
    private let spacing: CGFloat = 22
    private let buttonSize: CGFloat = 52 // Approximate button size (44 icon + 4 padding * 2)
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let calculatedColumns = calculateColumns(for: availableWidth)
            
            ScrollView {
                VStack {
                    Spacer()
                    
                    LazyVGrid(
                        columns: calculatedColumns,
                        alignment: .center,
                        spacing: spacing
                    ) {
                        ForEach(controls) { control in
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
                                    if let sourceIndex = controls.firstIndex(of: draggedItem),
                                       let destinationIndex = controls.firstIndex(of: control) {
                                        withAnimation(.bouncy) {
                                            let sourceControl = controls.remove(at: sourceIndex)
                                            controls.insert(sourceControl, at: destinationIndex)
                                            saveOrder()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            setupControls()
        }
        .animation(.bouncy, value: draggedItem)
    }
    
    private func getAvailableControls() -> [ControlType] {
        switch model.vehicle?.vehicleConfig.model {
        case .unknown, .air:
            return ControlType.allCases
        case .gravity:
            return ControlType.allCasesGravity
        case .UNRECOGNIZED, nil:
            return []
        }
    }
    
    private func calculateColumns(for width: CGFloat) -> [GridItem] {
        let minButtonWidth = buttonSize + spacing
        let maxColumns = min(6, max(2, Int(width / minButtonWidth)))
        
        return Array(repeating: GridItem(.flexible(minimum: buttonSize)), count: maxColumns)
    }
    
    private func setupControls() {
        let availableControls = getAvailableControls()
        
        let savedOrderArray = allControlsOrder.split(separator: ",").compactMap({ ControlType(rawValue: String($0)) })
        
        if !savedOrderArray.isEmpty {
            // Use saved order, filtering to only include available controls
            var ordered: [ControlType] = []
            var remaining = Set(availableControls)
            
            // Add controls in saved order
            for control in savedOrderArray {
                if remaining.contains(control) {
                    ordered.append(control)
                    remaining.remove(control)
                }
            }
            
            // Add any new controls that weren't in the saved order
            ordered.append(contentsOf: remaining.sorted(by: { $0.rawValue < $1.rawValue }))
            
            controls = ordered
        } else {
            // No saved order, use default order
            controls = availableControls
        }
    }
    
    private func saveOrder() {
        allControlsOrder = controls.map(\.rawValue).joined(separator: ",")
    }
}

#Preview {
    AllControlsGrid()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .padding()
}

