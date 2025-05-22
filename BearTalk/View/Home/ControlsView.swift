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
            .navigationTitle(model.vehicle?.vehicleConfig.nickname ?? "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogOutWarning = true
                    } label: {
                        Image(systemName: "person.circle")
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
                ClimateControlSheet()
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
            }
        }
    }
}

#Preview {
    ControlsView()
        .environmentObject(AppState())
        .environment(DataModel())
}
