//
//  HomeView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    @State var vehicle: Vehicle?
    @State var noVehicleWarning: String = ""

    @State var doorImage: String = LockState.locked.image
    @State var frunkImage: String = ClosureState.closed.frunkImage
    @State var trunkImage: String = ClosureState.closed.trunkImage
    @State var chargePortImage: String = ClosureState.closed.chargePortImage
    @State var lightsImage: String = LightsAction.off.lightsImage
    @State var flashLightsImage: String = LightsAction.flash.lightsImage

    var body: some View {
        NavigationStack {
            VStack {
                if let vehicle {
                    List {
                        HomeCell(title: "Doors", action: toggleDoorLocks, image: $doorImage)
                        HomeCell(title: "Frunk", action: toggleFrunk, image: $frunkImage)
                        HomeCell(title: "Trunk", action: toggleTrunk, image: $trunkImage)
                        HomeCell(title: "Charge Port", action: toggleChargePort, image: $chargePortImage)
                        HomeCell(title: "Lights", action: toggleLights, image: $lightsImage)
                        HomeCell(title: "Flash Lights", action: flashLights, image: $flashLightsImage)
                    }
                    .listStyle(.plain)

                } else {
                    Text(noVehicleWarning)
                }
                Spacer()
            }
            .padding()
            .task {
                await fetchVehicle()
            }
            .navigationTitle(vehicle?.vehicleConfig.nickname ?? "")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        logOut()
                    } label: {
                        Text("Log Out")
                    }
                }
            }
            .onChange(of: vehicle) { _, newValue in
                guard let newValue else { return }

                doorImage = LockState(rawValue: newValue.vehicleState.bodyState.doorLocks)?.image ?? "questionMark"
                frunkImage = ClosureState(rawValue: newValue.vehicleState.bodyState.frontCargo)?.frunkImage ?? "questionMark"
                trunkImage = ClosureState(rawValue: newValue.vehicleState.bodyState.rearCargo)?.trunkImage ?? "questionMark"
                chargePortImage = ClosureState(rawValue: newValue.vehicleState.bodyState.chargePortState)?.chargePortImage ?? "questionMark"
                lightsImage = LightsAction(rawValue: newValue.vehicleState.chassisState.headlightState)?.lightsImage ?? "questionMark"
            }
        }
    }

    private func logOut() {
        Task {
            let loggedOut = try await BearAPI.logOut()

            if loggedOut {
                appState.loggedIn = false
            }
        }
    }

    private func toggleDoorLocks() {
        if let lockState = LockState(rawValue: vehicle?.vehicleState.bodyState.doorLocks ?? "") {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch lockState {
                    case .unknown:
                        break
                    case .locked:
                        let success = try await BearAPI.doorLockControl(lockState: .unlocked)
                        if success {
                            vehicle?.vehicleState.bodyState.doorLocks = LockState.unlocked.rawValue
                        }
                    case .unlocked:
                        let success = try await BearAPI.doorLockControl(lockState: .locked)
                        if success {
                            vehicle?.vehicleState.bodyState.doorLocks = LockState.locked.rawValue
                        }
                    }
                } catch let error {
                    print("Could not change door lock state: \(error)")
                }
            }
        }
    }

    private func toggleFrunk() {
        toggleCargo(area: .frunk)
    }

    private func toggleTrunk() {
        toggleCargo(area: .trunk)
    }

    private func toggleCargo(area: Cargo) {
        if let closureState = ClosureState(rawValue: vehicle?.vehicleState.bodyState.frontCargo ?? "") {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch closureState {
                    case .open:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .closed)
                        if success {
                            vehicle?.vehicleState.bodyState.frontCargo = ClosureState.closed.rawValue
                        }
                    case .closed:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .open)
                        if success {
                            vehicle?.vehicleState.bodyState.frontCargo = ClosureState.open.rawValue
                        }
                    }
                } catch let error {
                    print("Could not toggle frunk state: \(error)")
                }
            }
        }
    }

    private func toggleChargePort() {
        if let closureState = ClosureState(rawValue: vehicle?.vehicleState.bodyState.chargePortState ?? "") {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch closureState {
                    case .open:
                        let success = try await BearAPI.chargePortControl(closureState: .closed)
                        if success {
                            vehicle?.vehicleState.bodyState.chargePortState = ClosureState.closed.rawValue
                        }
                    case .closed:
                        let success = try await BearAPI.chargePortControl(closureState: .open)
                        if success {
                            vehicle?.vehicleState.bodyState.chargePortState = ClosureState.open.rawValue
                        }
                    }
                } catch let error {
                    print("Could not toggle chargePort state: \(error)")
                }
            }
        }
    }

    private func toggleLights() {
        if let lightsAction = LightsAction(rawValue: vehicle?.vehicleState.chassisState.headlightState ?? "") {
            switch lightsAction {
            case .on:
                lights(action: .on)
            case .off:
                lights(action: .off)
            case .flash:
                break
            }
        }
    }

    private func flashLights() {
        lights(action: .flash)
    }

    private func lights(action: LightsAction) {
        Task {
            do {
                let _ = try await BearAPI.wakeUp()

                switch action {
                case .on:
                    let success = try await BearAPI.lightsControl(action: .off)
                    if success {
                        vehicle?.vehicleState.chassisState.headlightState = LightsAction.off.rawValue
                    }
                case .off:
                    let success = try await BearAPI.lightsControl(action: .on)
                    if success {
                        vehicle?.vehicleState.chassisState.headlightState = LightsAction.on.rawValue
                    }
                case .flash:
                    let _ = try await BearAPI.lightsControl(action: .flash)
                }
            } catch let error {
                print("Could not toggle light state: \(error)")
            }
        }
    }

    private func fetchVehicle() async {
        do {
            let fetched = try await BearAPI.fetchVehicles()
            vehicle = fetched
        } catch let error {
            print("Error fetching vehicles \(error)")
            noVehicleWarning = "No vehicles found"
        }
    }
}

#Preview {
    HomeView()
}
