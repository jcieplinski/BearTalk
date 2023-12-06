//
//  ControlsViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/6/23.
//

import SwiftUI

@Observable final class ControlsViewModel {
    var vehicle: Vehicle?
    var noVehicleWarning: String = ""
    var powerState: PowerState = .sleep
    var chargePercentage: String = ""
    var exteriorTemp: String = ""

    var doorImage: String = LockState.locked.image
    var frunkImage: String = ClosureState.closed.frunkImage
    var trunkImage: String = ClosureState.closed.trunkImage
    var chargePortImage: String = ClosureState.closed.chargePortImage
    var defrostImage: String = DefrostAction.off.defrostImage
    var lightsImage: String = LightsAction.off.lightsImage
    var flashLightsImage: String = LightsAction.flash.lightsImage
    var hornImage: String = "hornOff"

    var lockState: LockState?
    var frunkClosureState: ClosureState?
    var trunkClosureState: ClosureState?
    var chargePortClosureState: ClosureState?
    var lightsState: LightsAction?
    var defrostState: DefrostAction?

    var vehicleIsReady: Bool {
        if let powerState = PowerState(rawValue: vehicle?.vehicleState.powerState ?? "") {
            switch powerState {
            case .unknown, .sleep, .sleepCharge, .cloudOne, .cloudTwo:
                return false
            case .monitor, .accessory, .wink, .liveCharge, .liveUpdate:
                return true
            }
        }

        return false
    }

    func updateHomeImages() {
        guard let vehicle else { return }

        lockState = LockState(rawValue: vehicle.vehicleState.bodyState.doorLocks)
        frunkClosureState = ClosureState(rawValue: vehicle.vehicleState.bodyState.frontCargo)
        trunkClosureState = ClosureState(rawValue: vehicle.vehicleState.bodyState.rearCargo)
        chargePortClosureState = ClosureState(rawValue: vehicle.vehicleState.bodyState.chargePortState)
        lightsState = LightsAction(rawValue: vehicle.vehicleState.chassisState.headlightState)
        defrostState = DefrostAction(rawValue: vehicle.vehicleState.hvacStatus.defrost)

        doorImage = lockState?.image ?? "questionmark"
        frunkImage = frunkClosureState?.frunkImage ?? "questionmark"
        trunkImage = trunkClosureState?.trunkImage ?? "questionmark"
        chargePortImage = chargePortClosureState?.chargePortImage ?? "questionmark"
        lightsImage = lightsState?.lightsImage ?? "questionmark"
        defrostImage = defrostState?.defrostImage ?? "questionmark"
        hornImage = "hornOff"
        powerState = PowerState(rawValue: vehicle.vehicleState.powerState) ?? .unknown
        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"

        let exteriorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.exteriorTemp, unit: UnitTemperature.celsius)
        let exteriorTempMeasurementConverted = exteriorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))

        exteriorTemp = "\(exteriorTempMeasurementConverted.value.rounded()) \(exteriorTempMeasurementConverted.unit.symbol)"
    }

    func toggleDoorLocks() {
        if let lockState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }

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
        if let closureState = area == .frunk ? frunkClosureState : trunkClosureState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }

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
        if let closureState = chargePortClosureState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }

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
        if let action = defrostState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }

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
        if let lightsAction = lightsState {
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
                if !vehicleIsReady {
                    let _ = try await BearAPI.wakeUp()
                }

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
            if let fetched = try await BearAPI.fetchCurrentVehicle() {
                vehicle = fetched
            }
        } catch let error {
            print("Error fetching vehicles \(error)")
            noVehicleWarning = "No vehicles found"
        }
    }

    func honkHorn() {
        Task {
            do {
                if !vehicleIsReady {
                    let _ = try await BearAPI.wakeUp()
                }
                
                let _ = try await BearAPI.honkHorn()
            } catch let error {
                print("Could not honk horn: \(error)")
            }
        }
    }

    // MARK: - Preview
    static var preview: ControlsViewModel {
        let model = ControlsViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
