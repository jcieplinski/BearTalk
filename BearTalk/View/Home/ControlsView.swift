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

    @Bindable var model: ControlsViewModel

    @State var showLogOutWarning: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                if model.vehicle != nil {
                    // Top Row Status
                    Text(model.chargePercentage)
                        .font(.title)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .leading) {
                            Image(systemName: model.powerState.image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 18)
                        }
                        .overlay(alignment: .trailing) {
                            Text(model.exteriorTemp)
                                .font(.body)
                        }
                    VStack {
                        HStack(spacing: 6) {
                            // Left Side Controls
                            VStack {
                                Spacer()
                                Button {
                                    model.toggleChargePort()
                                } label: {
                                    Image(model.chargePortImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 52)
                                        .overlay(alignment: .trailing) {
                                            Rectangle()
                                                .frame(width: 110, height: 1)
                                                .offset(x: 110)
                                        }
                                        .tint(model.chargePortClosureState == .open ? .active : .inactive)
                                }
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(width: 11, height: 50)
                                Button {
                                    model.toggleDoorLocks()
                                } label: {
                                    Image(model.doorImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 52)
                                        .overlay(alignment: .trailing) {
                                            Rectangle()
                                                .frame(width: 110, height: 1)
                                                .offset(x: 110)
                                        }
                                        .tint(model.lockState == .locked ? .active : .inactive)
                                }
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(width: 11, height: 30)
                                Spacer()
                            }
                            // Car
                            HStack {
                                Rectangle()
                                    .foregroundStyle(.clear)
                                    .frame(maxHeight: 400)
                                    .background(
                                        Image(appState.carColor)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .padding(8)
                                    )
                            }
                            // Right Side Controls
                            VStack {
                                Button {
                                    model.toggleFrunk()
                                } label: {
                                    Image(model.frunkImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 52)
                                        .overlay(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: 110, height: 1)
                                                .offset(x: -110)
                                        }
                                        .tint(model.frunkClosureState == .open ? .active : .inactive)
                                        .padding(.bottom, 120)
                                }
                                Button {
                                    model.toggleTrunk()
                                } label: {
                                    Image(model.trunkImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 52)
                                        .overlay(alignment: .leading) {
                                            Rectangle()
                                                .frame(width: 110, height: 1)
                                                .offset(x: -110)
                                        }
                                        .tint(model.trunkClosureState == .open ? .active : .inactive)
                                        .padding(.top, 120)
                                }
                            }
                        }
                        Spacer()
                        HStack(spacing: 44) {
                            Button {
                                model.toggleDefost()
                            } label: {
                                Image(model.defrostImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52)
                                    .tint(model.defrostState == .on ? .active : .inactive)
                            }
                            Button {
                                model.toggleLights()
                            } label: {
                                Image(model.lightsImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52)
                                    .tint(model.lightsState == .on ? .active : .inactive)
                            }
                            Button {
                                model.flashLights()
                            } label: {
                                Image(model.flashLightsImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52)
                            }
                            Button {
                                model.honkHorn()
                            } label: {
                                Image(model.hornImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 52)
                            }
                        }
                    }
                    Spacer()
                } else {
                    EmptyView()
                }
            }
            .tint(.accent)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                await model.fetchVehicle()
                model.updateHomeImages()
            }
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
    ControlsView(model: ControlsViewModel.preview)
        .environmentObject(AppState())
}
