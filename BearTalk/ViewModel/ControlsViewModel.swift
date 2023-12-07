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
    var gearPosition: GearPosition = .unknown

    var hornActive: Bool = false {
        didSet {
            hornImage = hornActive ? "hornOn" : "hornOff"
        }
    }

    var lightsFlashActive: Bool = false {
        didSet {
            flashLightsImage = lightsFlashActive ? "flashLightsOn" : "flashLightsOff"
        }
    }

    var requestInProgress: ControlFunction?

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

    func update() {
        guard let vehicle else { return }

        gearPosition = GearPosition(rawValue: vehicle.vehicleState.gearPosition) ?? .unknown

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
        hornImage = hornActive ? "hornOn" : "hornOff"
        flashLightsImage = lightsFlashActive ? "flashLightsOn" : "flashLightsOff"
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

                    requestInProgress = .doorLocks

                    switch lockState {
                    case .unknown:
                        break
                    case .locked:
                        let success = try await BearAPI.doorLockControl(lockState: .unlocked)
                        if success {
                            setToggleCheckTimer(.doorLocks)
                        }
                    case .unlocked:
                        let success = try await BearAPI.doorLockControl(lockState: .locked)
                        if success {
                            setToggleCheckTimer(.doorLocks)
                        }
                    }
                } catch let error {
                    print("Could not change door lock state: \(error)")
                }
            }
        }
    }

    func setToggleCheckTimer(_ control: ControlFunction) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1000)) { [self] in
            switch control {
            case .doorLocks:
                checkDoorToggle()
            case .frunk:
                checkFrunkToggle()
            case .trunk:
                checkTrunkToggle()
            case .chargePort:
                checkChargePortToggle()
            case .defrost:
                checkDefrostToggle()
            case .lights:
                checkLightsToggle()
            case .flash:
                checkLightsFlash()
            case .horn:
                checkHornToggle()
            }
        }
    }

    func checkDoorToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let lockState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.vehicleUnlockReq {
                    if lockState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.doorLocks)
                    }
                }
            } catch {
                print("Unable to check on door locks: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkChargePortToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let chargePortClosureState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.chargePortReq {
                    if chargePortClosureState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.chargePort)
                    }
                }
            } catch {
                print("Unable to check on chargePort: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkFrunkToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let frunkClosureState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.frunkCargoReq {
                    if frunkClosureState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.frunk)
                    }
                }
            } catch {
                print("Unable to check on frunk: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkTrunkToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let trunkClosureState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.frunkCargoReq {
                    if trunkClosureState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.trunk)
                    }
                }
            } catch {
                print("Unable to check on trunk: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkDefrostToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let defrostState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.hvacDefrostEnable {
                    if defrostState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.defrost)
                    }
                }
            } catch {
                print("Unable to check on defrost: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkLightsToggle() {
        Task {
            do {
                let vehicle = try await BearAPI.fetchCurrentVehicle()
                if let vehicle { self.vehicle = vehicle }

                if let lightsState, let requestState = vehicle?.vehicleState.mobileAppReqStatus.lightReq {
                    if lightsState.rawValue == requestState {
                        requestInProgress = nil
                    } else {
                        setToggleCheckTimer(.lights)
                    }
                }
            } catch {
                print("Unable to check on defrost: \(error)")
                requestInProgress = nil
            }
        }
    }

    func checkLightsFlash() {
        Task {
            lightsFlashActive = false
            requestInProgress = nil
        }
    }

    func checkHornToggle() {
        Task {
            hornActive = false
            requestInProgress = nil
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

                    requestInProgress = area == .frunk ? .frunk : .trunk

                    switch closureState {
                    case .open:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .closed)
                        if success {
                            switch area {
                            case .frunk:
                                setToggleCheckTimer(.frunk)
                            case .trunk:
                                setToggleCheckTimer(.trunk)
                            }
                        }
                    case .closed:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .open)
                        if success {
                            switch area {
                            case .frunk:
                                setToggleCheckTimer(.frunk)
                            case .trunk:
                                setToggleCheckTimer(.trunk)
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

                    requestInProgress = .chargePort

                    switch closureState {
                    case .open:
                        let success = try await BearAPI.chargePortControl(closureState: .closed)
                        if success {
                            setToggleCheckTimer(.chargePort)
                        }
                    case .closed:
                        let success = try await BearAPI.chargePortControl(closureState: .open)
                        if success {
                            setToggleCheckTimer(.chargePort)
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

                    requestInProgress = .defrost

                    switch action {
                    case .on:
                        let success = try await BearAPI.defrostControl(action: .off)
                        if success {
                            setToggleCheckTimer(.defrost)
                        }
                    case .off:
                        let success = try await BearAPI.defrostControl(action: .on)
                        if success {
                            setToggleCheckTimer(.defrost)
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
                    requestInProgress = .lights

                    let success = try await BearAPI.lightsControl(action: .off)
                    if success {
                        setToggleCheckTimer(.lights)
                    }
                case .off:
                    requestInProgress = .lights

                    let success = try await BearAPI.lightsControl(action: .on)
                    if success {
                        setToggleCheckTimer(.lights)
                    }
                case .flash:
                    lightsFlashActive = true
                    requestInProgress = .flash

                    let _ = try await BearAPI.lightsControl(action: .flash)
                    setToggleCheckTimer(.flash)
                }
            } catch let error {
                print("Could not toggle light state: \(error)")
            }
        }
    }

    func honkHorn() {
        Task {
            do {
                if !vehicleIsReady {
                    let _ = try await BearAPI.wakeUp()
                }

                requestInProgress = .horn

                let _ = try await BearAPI.honkHorn()
                checkHornToggle()
            } catch let error {
                print("Could not honk horn: \(error)")
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
    static var preview: ControlsViewModel {
        let model = ControlsViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
