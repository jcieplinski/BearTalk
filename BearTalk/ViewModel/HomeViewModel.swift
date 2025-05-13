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
    var frunkImage: String = DoorState.closed.frunkImage
    var trunkImage: String = DoorState.closed.trunkImage
    var chargePortImage: String = DoorState.closed.chargePortImage
    var defrostImage: String = DefrostAction.off.defrostImage
    var lightsImage: String = LightsAction.off.lightsImage
    var flashLightsImage: String = LightsAction.flash.lightsImage

    func updateHomeImages() {
        guard let vehicle else { return }

        doorImage = vehicle.vehicleState.bodyState.doorLocks.image
        frunkImage = vehicle.vehicleState.bodyState.frontCargo.frunkImage
        trunkImage = vehicle.vehicleState.bodyState.rearCargo.trunkImage
        chargePortImage = vehicle.vehicleState.bodyState.chargePortState.chargePortImage
        lightsImage = vehicle.vehicleState.mobileAppReqStatus.lightRequest.lightsImage
        defrostImage = vehicle.vehicleState.hvacState.defrost.defrostImage
        powerState = vehicle.vehicleState.powerState
    }

    func toggleDoorLocks() {
        if let lockState = vehicle?.vehicleState.bodyState.doorLocks {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch lockState {
                    case .unknown:
                        break
                    case .locked:
                        let success = try await BearAPI.doorLockControl(lockState: .unlocked)
                        if success {
                            vehicle?.vehicleState.bodyState.doorLocks = LockState.unlocked
                        }
                    case .unlocked:
                        let success = try await BearAPI.doorLockControl(lockState: .locked)
                        if success {
                            vehicle?.vehicleState.bodyState.doorLocks = LockState.locked
                        }
                    case .UNRECOGNIZED(_):
                        break
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
        if let closureState = rawValue {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch closureState {
                    case .open, .ajar:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .closed)
                        if success {
                            switch area {
                            case .frunk:
                                vehicle?.vehicleState.bodyState.frontCargo = DoorState.closed
                            case .trunk:
                                vehicle?.vehicleState.bodyState.rearCargo = DoorState.closed
                            }
                        }
                    case .closed:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .open)
                        if success {
                            switch area {
                            case .frunk:
                                vehicle?.vehicleState.bodyState.frontCargo = DoorState.open
                            case .trunk:
                                vehicle?.vehicleState.bodyState.rearCargo = DoorState.open
                            }
                        }
                    case .unknown, .UNRECOGNIZED(_):
                        break
                    }
                } catch let error {
                    print("Could not toggle cargo area \(area.controlURL) state: \(error)")
                }
            }
        }
    }

    func toggleChargePort() {
        if let closureState = vehicle?.vehicleState.bodyState.chargePortState {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch closureState {
                    case .open, .ajar:
                        let success = try await BearAPI.chargePortControl(closureState: .closed)
                        if success {
                            vehicle?.vehicleState.bodyState.chargePortState = DoorState.closed
                        }
                    case .closed:
                        let success = try await BearAPI.chargePortControl(closureState: .open)
                        if success {
                            vehicle?.vehicleState.bodyState.chargePortState = DoorState.open
                        }
                    case .unknown, .UNRECOGNIZED(_):
                        break
                    }
                } catch let error {
                    print("Could not toggle chargePort state: \(error)")
                }
            }
        }
    }

    func toggleDefost() {
        if let action = vehicle?.vehicleState.hvacState.defrost {
            Task {
                do {
                    let _ = try await BearAPI.wakeUp()

                    switch action {
                    case .defrostOn:
                        let success = try await BearAPI.defrostControl(action: .off)
                        if success {
                            vehicle?.vehicleState.hvacState.defrost = DefrostState.defrostOff
                        }
                    case .defrostOff:
                        let success = try await BearAPI.defrostControl(action: .on)
                        if success {
                            vehicle?.vehicleState.hvacState.defrost = DefrostState.defrostOn
                        }
                    case .unknown, .UNRECOGNIZED(_):
                        break
                    }
                } catch let error {
                    print("Could not toggle defrost state: \(error)")
                }
            }
        }
    }

    func toggleLights() {
        if let lightsAction = vehicle?.vehicleState.chassisState.headlights {
            switch lightsAction {
            case .on:
                lights(action: .on)
            case .off:
                lights(action: .off)
            case .UNRECOGNIZED(_), .reallyUnknown, .unknown:
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
                        vehicle?.vehicleState.chassisState.headlights = LightState.off
                    }
                case .off:
                    let success = try await BearAPI.lightsControl(action: .on)
                    if success {
                        vehicle?.vehicleState.chassisState.headlights = LightState.on
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
            if let fetched = try await BearAPI.fetchCurrentVehicle() {
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
