//
//  ControlsView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/6/23.
//

import SwiftUI

struct ControlsView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var appState: AppState
    @Environment(DataModel.self) var model

    @State var showLogOutWarning: Bool = false
    @State var showClimateControl: Bool = false
    @State var showSeatClimate: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if model.vehicle != nil {
                        // Top Row Status
                        Text(model.chargePercentage)
                            .font(.title)
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .leading) {
                                Button {
                                    if !model.vehicleIsReady {
                                        model.wakeUpCar()
                                    }
                                } label: {
                                    Image(systemName: model.powerState.image)
                                        .font(.body)
                                        .fontWeight(.bold)
                                }
                            }
                            .overlay(alignment: .trailing) {
                                Text(model.exteriorTemp)
                                    .font(.body)
                            }
                        
                        VStack {
                            CarView()
                            
                            ControlGrid()
                        }
                        
                        VStack(spacing: 16) {
                            ClimateControlsCell()
                            ChargingCell()
                        }
                        .padding()
                        
                        Spacer()
                    } else {
                        EmptyView()
                    }
                }
                .tint(.accent)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .scrollBounceBehavior(.basedOnSize)
            .animation(.default, value: model.showingAvailableControls)
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
                                }
                            } label: {
                                Text(vehicle.nickname)
                            }
                        }
                        
                        Divider()
                        
                        Button(role: .destructive) {
                            showLogOutWarning = true
                        } label: {
                            Label("Log Out", systemImage: "person.circle")
                        }
                    } label: {
                        if let photoUrl = model.userProfile?.photoUrl {
                            AsyncImage(url: URL(string: photoUrl)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .clipShape(Circle())
                            } placeholder: {
                                Image(systemName: "person.circle")
                            }
                        } else {
                            Image(systemName: "person.circle")
                        }
                    }
                }
            }
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
            .alert("Are you Sure?", isPresented: $showLogOutWarning) {
                Button("Log Out", role: .destructive) {
                    appState.logOut()
                }
                Button("Cancel", role: .cancel) {
                    showLogOutWarning = false
                }
            } message: {
                Text("Do you wish to log out of your Lucid account?")
            }
            .sheet(isPresented: $showClimateControl) {
                ClimateControlSheet(modalPresented: true)
                    .presentationBackground(.thinMaterial)
            }
            .sheet(isPresented: $showSeatClimate) {
                SeatClimateSheet(modalPresented: true)
                    .presentationBackground(.thinMaterial)
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
            }
        }
    }
}

#Preview {
    ControlsView()
        .environmentObject(AppState())
        .environment(DataModel())
}
