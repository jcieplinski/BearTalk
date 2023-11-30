//
//  HomeView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    @Bindable var model: HomeViewModel = HomeViewModel()

    @State var showLogOutWarning: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 2) {
                if model.vehicle != nil {
                    Image(appState.carColor)
                        .resizable()
                        .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                        .rotationEffect(.degrees(90))
                        .frame(width: 100, height: 100)
                        .padding(8)
                    List {
                        HomeCell(title: "Doors", action: model.toggleDoorLocks, image: $model.doorImage)
                        HomeCell(title: "Frunk", action: model.toggleFrunk, image: $model.frunkImage)
                        HomeCell(title: "Trunk", action: model.toggleTrunk, image: $model.trunkImage)
                        HomeCell(title: "Charge Port", action: model.toggleChargePort, image: $model.chargePortImage)
                        HomeCell(title: "Defrost", action: model.toggleDefost, image: $model.defrostImage)
                        HomeCell(title: "Lights", action: model.toggleLights, image: $model.lightsImage)
                        HomeCell(title: "Flash Lights", action: model.flashLights, image: $model.flashLightsImage)
                    }
                    .scrollContentBackground(.hidden)
                    .listStyle(.plain)

                } else {
                    Text(model.noVehicleWarning)
                }
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .task {
                await model.fetchVehicle()
            }
            .navigationTitle(model.vehicle?.vehicleConfig.nickname ?? "")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showLogOutWarning = true
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .onChange(of: model.vehicle) { _, newValue in
                guard newValue != nil else { return }

                model.updateHomeImages()
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

        }
    }
}

#Preview {
    HomeView(model: HomeViewModel.preview)
        .environmentObject(AppState())
}
