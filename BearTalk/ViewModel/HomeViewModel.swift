//
//  HomeViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

@Observable final class HomeViewModel {
    var vehicle: Vehicle?
    var noVehicleWarning: String = ""
    var powerState: PowerState = .sleep

    var doorImage: String = LockState.locked.image
    var frunkImage: String = ClosureState.closed.frunkImage
    var trunkImage: String = ClosureState.closed.trunkImage
    var chargePortImage: String = ClosureState.closed.chargePortImage
    var defrostImage: String = DefrostAction.off.defrostImage
    var lightsImage: String = LightsAction.off.lightsImage
    var flashLightsImage: String = LightsAction.flash.lightsImage

    func updateHomeImages() {
        guard let vehicle else { return }

        doorImage = LockState(rawValue: vehicle.vehicleState.bodyState.doorLocks)?.image ?? "questionmark"
        frunkImage = ClosureState(rawValue: vehicle.vehicleState.bodyState.frontCargo)?.frunkImage ?? "questionmark"
        trunkImage = ClosureState(rawValue: vehicle.vehicleState.bodyState.rearCargo)?.trunkImage ?? "questionmark"
        chargePortImage = ClosureState(rawValue: vehicle.vehicleState.bodyState.chargePortState)?.chargePortImage ?? "questionmark"
        lightsImage = LightsAction(rawValue: vehicle.vehicleState.chassisState.headlightState)?.lightsImage ?? "questionmark"
        defrostImage = DefrostAction(rawValue: vehicle.vehicleState.hvacStatus.defrost)?.defrostImage ?? "questionmark"
        powerState = PowerState(rawValue: vehicle.vehicleState.powerState) ?? .unknown
    }

    func toggleDoorLocks() {
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

    func toggleFrunk() {
        toggleCargo(area: .frunk)
    }

    func toggleTrunk() {
        toggleCargo(area: .trunk)
    }

    func toggleCargo(area: Cargo) {
        let rawValue = area == .frunk ? vehicle?.vehicleState.bodyState.frontCargo : vehicle?.vehicleState.bodyState.rearCargo
        if let closureState = ClosureState(rawValue: rawValue ?? "") {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch closureState {
                    case .open:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .closed)
                        if success {
                            switch area {
                            case .frunk:
                                vehicle?.vehicleState.bodyState.frontCargo = ClosureState.closed.rawValue
                            case .trunk:
                                vehicle?.vehicleState.bodyState.rearCargo = ClosureState.closed.rawValue
                            }
                        }
                    case .closed:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .open)
                        if success {
                            switch area {
                            case .frunk:
                                vehicle?.vehicleState.bodyState.frontCargo = ClosureState.open.rawValue
                            case .trunk:
                                vehicle?.vehicleState.bodyState.rearCargo = ClosureState.open.rawValue
                            }
                        }
                    }
                } catch let error {
                    print("Could not toggle cargo area \(area.controlURL) state: \(error)")
                }
            }
        }
    }

    func toggleChargePort() {
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

    func toggleDefost() {
        if let action = DefrostAction(rawValue: vehicle?.vehicleState.hvacStatus.defrost ?? "") {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch action {
                    case .on:
                        let success = try await BearAPI.defrostControl(action: .off)
                        if success {
                            vehicle?.vehicleState.hvacStatus.defrost = DefrostAction.off.rawValue
                        }
                    case .off:
                        let success = try await BearAPI.defrostControl(action: .on)
                        if success {
                            vehicle?.vehicleState.hvacStatus.defrost = DefrostAction.on.rawValue
                        }
                    }
                } catch let error {
                    print("Could not toggle defrost state: \(error)")
                }
            }
        }
    }

    func toggleLights() {
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

    func flashLights() {
        lights(action: .flash)
    }

    func lights(action: LightsAction) {
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

    func fetchVehicle() async {
        do {
            if let fetched = try await BearAPI.fetchVehicles() {
                vehicle = fetched
            }
        } catch let error {
            print("Error fetching vehicles \(error)")
            noVehicleWarning = "No vehicles found"
        }
    }

    // MARK: - Preview
    static var preview: HomeViewModel {
        let model = HomeViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
