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
                    
                    requestInProgress = area == .frunk ? .frunk : .trunk
                    
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
                    
                    requestInProgress = .chargePort
                    
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
    
    func toggleDefost() {
        if let action = defrostState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress = .defrost
                    
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
                    requestInProgress = .lights
                    
                    let success = try await BearAPI.lightsControl(action: .off)
                    if !success {
                        // put up an alert
                    }
                case .off:
                    requestInProgress = .lights
                    
                    let success = try await BearAPI.lightsControl(action: .on)
                    if !success {
                        // put up an alert
                    }
                case .flash:
                    lightsFlashActive = true
                    requestInProgress = .flash
                    
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
                
                requestInProgress = .horn
                
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
                requestInProgress = .wake
                let success = try await BearAPI.wakeUp()
                if !success {
                    // put up an alert
                }
            } catch {
                print("Could not wake car: \(error)")
            }
        }
    }
}
