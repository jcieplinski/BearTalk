//
//  ControlsView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/6/23.
//

import SwiftUI

struct ControlsView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(AppState.self) var appState: AppState
    @Environment(DataModel.self) var model
    @AppStorage(DefaultsKey.cellOrder, store: .appGroup) private var cellOrder: String = "climate,charging,security,windows"

    @State private var showLogOutWarning: Bool = false
    @State private var showClimateControl: Bool = false
    @State private var showSeatClimate: Bool = false
    @State private var showSettings: Bool = false
    @State private var showWindowControls: Bool = false
    @State private var draggedCell: String?
    
    private var orderedCells: [String] {
        cellOrder.split(separator: ",").map(String.init)
    }
    
    private func cellView(for type: String) -> some View {
        Group {
            switch type {
            case "climate":
                ClimateControlsCell()
            case "charging":
                ChargingCell()
            case "security":
                SecurityCell()
            case "windows":
                WindowsCell()
            default:
                EmptyView()
            }
        }
        .onDrag {
            draggedCell = type
            let provider = NSItemProvider(object: type as NSString)
            provider.suggestedName = type
            return provider
        } preview: {
            EmptyView()
        }
        .onDrop(of: [.text], delegate: DropViewDelegate(
            item: type,
            items: orderedCells,
            draggedItem: $draggedCell,
            cellOrder: $cellOrder
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if model.vehicle != nil {
                        // Top Row Status
                        Text(model.chargePercentage)
                            .font(.title)
                            .dynamicTypeSize(.large)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .leading) {
                                Button {
                                    if !model.vehicleIsReady {
                                        model.wakeUpCar()
                                    }
                                } label: {
                                    ZStack {
                                        Image(systemName: model.vehicle?.vehicleState.driveMode == .service ? "exclamationmark.circle" : model.powerState.image)
                                            .font(.body)
                                            .dynamicTypeSize(.large)
                                            .fontWeight(.bold)
                                            .opacity(model.requestInProgress.contains(.wake) ? 0.3 : 1.0)
                                            .disabled(model.requestInProgress.contains(.wake) || model.allFunctionsDisable)
                                        
                                        if model.requestInProgress.contains(.wake) {
                                            ProgressView()
                                        }
                                    }
                                }
                                .padding()
                            }
                            .overlay(alignment: .trailing) {
                                Text(model.exteriorTemp)
                                    .font(.body)
                                    .dynamicTypeSize(.large)
                                    .padding()
                            }
                        
                        VStack {
                            CarView()
                            
                            ControlGrid()
                        }
                        
                        // Alert Cell
                        if !model.alerts.isEmpty {
                            AlertCell()
                                .padding(.horizontal)
                        }
                        
                        // Software Update Cell
                        SoftwareUpdateCell()
                            .padding(.horizontal)
                        
                        VStack(spacing: 16) {
                            ForEach(orderedCells, id: \.self) { cellType in
                                cellView(for: cellType)
                            }
                        }
                        .padding()
                        
                        Spacer()
                    } else {
                        EmptyView()
                    }
                }
                .tint(.accent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: model.showingAvailableControls)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: model.alerts)
            .navigationTitle(model.vehicle?.vehicleConfig.nickname ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(model.vehicleIdentifiers ?? [], id: \.id) { vehicle in
                            Button {
                                BearAPI.vehicleID = vehicle.id
                                Task {
                                    await model.refreshVehicle()
                                    // Refresh vehicle identifiers after switching
                                    model.vehicleIdentifiers = try? await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).fetch()
                                }
                            } label: {
                                Text(vehicle.nickname)
                            }
                        }
                        
                        Divider()
                        
                        Button {
                            showSettings = true
                        } label: {
                            Label("Settings", systemImage: "gear")
                        }
                    } label: {
                        if let photoUrl = model.userProfile?.photoUrl {
                            ProfileImageView(photoUrl: photoUrl)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.title2)
                        }
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.fraction(0.70), .large])
            }
            .sheet(isPresented: $showClimateControl) {
                ClimateControlSheet(modalPresented: true)
                    .presentationBackground(.thinMaterial)
            }
            .sheet(isPresented: $showSeatClimate) {
                SeatClimateSheet(modalPresented: true)
                    .presentationBackground(.thinMaterial)
            }
            .sheet(isPresented: $showWindowControls) {
                WindowsSheet(isModelPresntation: true)
                    .presentationBackground(.thinMaterial)
                    .presentationDetents([.fraction(0.55), .large])
            }
            .onAppear {
                NotificationCenter.default.addObserver(
                    forName: .showClimateControl,
                    object: nil,
                    queue: .main
                ) { _ in
                    showClimateControl = true
                }
                
                NotificationCenter.default.addObserver(
                    forName: .showSeatClimate,
                    object: nil,
                    queue: .main
                ) { _ in
                    showSeatClimate = true
                }
                
                NotificationCenter.default.addObserver(
                    forName: .showWindowControl,
                    object: nil,
                    queue: .main
                ) { _ in
                    showWindowControls = true
                }
            }
        }
    }
}

struct DropViewDelegate: DropDelegate {
    let item: String
    let items: [String]
    @Binding var draggedItem: String?
    @Binding var cellOrder: String
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem != item,
              let sourceIndex = items.firstIndex(of: draggedItem),
              let destinationIndex = items.firstIndex(of: item) else {
            return
        }
        
        withAnimation(.bouncy) {
            var newOrder = items
            let sourceCell = newOrder.remove(at: sourceIndex)
            newOrder.insert(sourceCell, at: destinationIndex)
            cellOrder = newOrder.joined(separator: ",")
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}

#Preview {
    ControlsView()
        .environment(AppState())
        .environment(DataModel())
}
