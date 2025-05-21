//
//  DataModel-Control.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI
import OSLog

extension DataModel {
    var allFunctionsDisable: Bool {
        if gearPosition != .gearPark { return true }
        
        if self.powerState == .liveUpdate { return true }
        
        return false
    }
    
    func handleControlAction(_ controlType: ControlType) {
        switch controlType {
        case .wake:
            break
        case .doorLocks:
            toggleDoorLocks()
        case .frunk:
            toggleFrunk()
        case .trunk:
            toggleTrunk()
        case .chargePort:
            toggleChargePort()
        case .climateControl:
            break
        case .maxAC:
            break
        case .seatClimate:
            break
        case .steeringWheelClimate:
            toggleSteeringWheelHeat()
        case .defrost:
            toggleDefost()
        case .horn:
            honkHorn()
        case .lights:
            toggleLights()
        case .batteryPrecondition:
            toggleBatteryPrecondition()
        }
    }
    
    func toggleDoorLocks() {
        if let lockState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(.doorLocks)
                    
                    switch lockState {
                    case .unknown:
                        break
                    case .locked:
                        let success = try await BearAPI.doorLockControl(lockState: .unlocked)
                        if !success {
                            // Put up an alert
                        }
                    case .unlocked:
                        let success = try await BearAPI.doorLockControl(lockState: .locked)
                        if !success {
                            // Put up an alert
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
        if let closureState = area == .frunk ? frunkClosureState : trunkClosureState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(area == .frunk ? .frunk : .trunk)
                    
                    switch closureState {
                    case .open, .ajar:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .closed)
                        if !success {
                            // put up an alert
                        }
                    case .closed:
                        let success = try await BearAPI.cargoControl(
                            area: area,
                            closureState: .open)
                        if !success {
                            // put up an alert
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
        if let closureState = chargePortClosureState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(.chargePort)
                    
                    switch closureState {
                    case .open, .ajar:
                        let success = try await BearAPI.chargePortControl(closureState: .closed)
                        if !success {
                            // put up an alert
                        }
                    case .closed:
                        let success = try await BearAPI.chargePortControl(closureState: .open)
                        if !success {
                            // put up an alert
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
    
    func toggleSteeringWheelHeat() {
        if let steeringHeaterStatus {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(.steeringWheelClimate)
                    
                    switch steeringHeaterStatus {
                    case .unknown, .UNRECOGNIZED:
                        break
                    case .off:
                        let success = try await BearAPI.setSteeringWheelHeat(status: .on)
                        if !success {
                            // put up an alert
                        }
                    case .on:
                        let success = try await BearAPI.setSteeringWheelHeat(status: .off)
                        if !success {
                            // put up an alert
                        }
                    }
                } catch let error {
                    print("Could not toggle steeringWheelHeat state: \(error)")
                }
            }
        }
    }
    
    func toggleBatteryPrecondition() {
        if let preconditionState = batteryPreConditionState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(.batteryPrecondition)
                    
                    switch preconditionState {
                        
                    case .batteryPreconUnknown, .batteryPreconUnavailable, .UNRECOGNIZED:
                        break
                    case .batteryPreconOff:
                        let success = try await BearAPI.setBatteryPreCondition(status: .batteryPreconOn)
                        if !success {
                            // put up an alert
                        }
                    case .batteryPreconOn:
                        let success = try await BearAPI.setBatteryPreCondition(status: .batteryPreconOff)
                        if !success {
                            // put up an alert
                        }
                    }
                } catch let error {
                    print("Could not toggle battery precondition state: \(error)")
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
                    
                    requestInProgress.insert(.defrost)
                    
                    switch action {
                    case .defrostOn:
                        let success = try await BearAPI.defrostControl(action: .defrostOff)
                        if !success {
                            // put up an alert
                        }
                    case .defrostOff:
                        let success = try await BearAPI.defrostControl(action: .defrostOn)
                        if !success {
                            // put up an alert
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
        if let lightAction = lightsState {
            switch lightAction {
            case .on:
                lights(action: .on)
            case .off:
                lights(action: .off)
            case .flash:
                break
            case .unknown:
                break
            case .UNRECOGNIZED(_):
                break
            case .hazardOn:
                break
            case .hazardOff:
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
                    requestInProgress.insert(.lights)
                    
                    let success = try await BearAPI.lightsControl(action: .off)
                    if !success {
                        // put up an alert
                    }
                case .off:
                    requestInProgress.insert(.lights)
                    
                    let success = try await BearAPI.lightsControl(action: .on)
                    if !success {
                        // put up an alert
                    }
                case .flash:
                 //   lightsFlashActive = true
                   // requestInProgress.insert(.flash)
                    
                    let success = try await BearAPI.lightsControl(action: .flash)
                    if !success {
                        // put up an alert
                    }
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
                
                requestInProgress.insert(.horn)
                
                let success = try await BearAPI.honkHorn()
                if !success {
                    // put up an alert
                }
            } catch let error {
                print("Could not honk horn: \(error)")
            }
        }
    }
    
    func wakeUpCar() {
        Task {
            do {
                requestInProgress.insert(.wake)
                let success = try await BearAPI.wakeUp()
                if !success {
                    // put up an alert
                }
            } catch {
                print("Could not wake car: \(error)")
            }
        }
    }
    
    func resetControlFunction(oldState: VehicleState?, newState: VehicleState?) {
        guard let oldState, let newState else {
            requestInProgress = []
            return
        }
        
        requestInProgress.forEach { request in
            switch request {
            case .doorLocks:
                if oldState.bodyState.doorLocks != newState.bodyState.doorLocks {
                    requestInProgress.remove(.doorLocks)
                }
            case .frunk:
                if oldState.bodyState.frontCargo != newState.bodyState.frontCargo {
                    requestInProgress.remove(.frunk)
                }
            case .trunk:
                if oldState.bodyState.rearCargo != newState.bodyState.rearCargo {
                    requestInProgress.remove(.trunk)
                }
            case .chargePort:
                if oldState.bodyState.chargePortState != newState.bodyState.chargePortState {
                    requestInProgress.remove(.chargePort)
                }
            case .defrost:
                if oldState.hvacState.defrost != newState.hvacState.defrost {
                    requestInProgress.remove(.defrost)
                }
            case .lights:
                if oldState.chassisState.headlights != newState.chassisState.headlights {
                    requestInProgress.remove(.lights)
                }
            case .horn:
                requestInProgress.remove(.horn)
            case .wake:
                if oldState.powerState != newState.powerState {
                    requestInProgress.remove(.wake)
                }
            case .climateControl:
                if oldState.hvacState.power != newState.hvacState.power {
                    requestInProgress.remove(.climateControl)
                }
            case .maxAC:
                if oldState.hvacState.maxAcStatus != newState.hvacState.maxAcStatus {
                    requestInProgress.remove(.maxAC)
                }
            case .seatClimate:
                if oldState.hvacState.seats.self != newState.hvacState.seats.self {
                    requestInProgress.remove(.seatClimate)
                }
            case .steeringWheelClimate:
                if oldState.hvacState.steeringHeater != newState.hvacState.steeringHeater {
                    requestInProgress.remove(.steeringWheelClimate)
                }
            case .batteryPrecondition:
                if oldState.batteryState.preconditioningStatus != newState.batteryState.preconditioningStatus {
                    requestInProgress.remove(.batteryPrecondition)
                }
            }
        }
    }
}
