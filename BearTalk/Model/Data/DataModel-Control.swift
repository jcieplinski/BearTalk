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
            NotificationCenter.default.post(name: .showClimateControl, object: nil)
        case .maxAC:
            toggleMaxAC()
        case .seatClimate:
            NotificationCenter.default.post(name: .showSeatClimate, object: nil)
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
        default:
            break
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
    
    func toggleMaxAC() {
        if let action = maxACState {
            Task {
                do {
                    if !vehicleIsReady {
                        let _ = try await BearAPI.wakeUp()
                    }
                    
                    requestInProgress.insert(.maxAC)
                    
                    switch action {
                    case .unknown, .UNRECOGNIZED:
                        break
                    case .off:
                        let success = try await BearAPI.setMaxAC(state: .on)
                        if !success {
                            // put up an alert
                        }
                    case .on:
                        let success = try await BearAPI.setMaxAC(state: .off)
                        if !success {
                            // put up an alert
                        }
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
    
    func toggleClimateControl() {
        Task {
            do {
                if !vehicleIsReady {
                    let _ = try await BearAPI.wakeUp()
                }
                
                requestInProgress.insert(.climateControl)
                
                switch climatePowerState ?? .hvacOff {
                case .unknown, .UNRECOGNIZED(_):
                    break
                case .hvacOn, .hvacPrecondition, .hvacKeepTemp:
                    let success = try await BearAPI.setClimateControlState(state: .hvacOff, temperature: selectedTemperature)
                    if !success {
                        // put up an alert
                    }
                case .hvacOff:
                    let success = try await BearAPI.setClimateControlState(state: .hvacPrecondition, temperature: selectedTemperature)
                    if !success {
                        // put up an alert
                    }
                }
            }
        }
    }
    
    func setCabinTemperature(_ temperature: Double) {
        Task {
            do {
                if !vehicleIsReady {
                    let _ = try await BearAPI.wakeUp()
                }
                
                requestInProgress.insert(.climateControl)
                
                let success = try await BearAPI.setTemperature(temperature: temperature)
                if !success {
                    // put up an alert
                }
            } catch {
                print("Could not set temperature: \(error)")
            }
        }
    }
    
    func resetControlFunction(oldState: VehicleState?, newState: VehicleState?) {
        guard let oldState, let newState else {
            requestInProgress = []
            return
        }
        
        let ogRequestInProgress = requestInProgress
        
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
                
                if oldState.hvacState.frontLeftSetTemperature != newState.hvacState.frontLeftSetTemperature {
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
            case .driverSeatHeat:
                if oldState.hvacState.seats.driverHeatBackrestZone1 != newState.hvacState.seats.driverHeatBackrestZone1 {
                    requestInProgress.remove(.driverSeatHeat)
                }
                
                if oldState.hvacState.seats.driverHeatBackrestZone3 != newState.hvacState.seats.driverHeatBackrestZone3 {
                    requestInProgress.remove(.driverSeatHeat)
                }
                
                if oldState.hvacState.seats.driverHeatCushionZone2 != newState.hvacState.seats.driverHeatCushionZone2 {
                    requestInProgress.remove(.driverSeatHeat)
                }
                
                if oldState.hvacState.seats.driverHeatCushionZone4 != newState.hvacState.seats.driverHeatCushionZone4 {
                    requestInProgress.remove(.driverSeatHeat)
                }
            case .driverSeatVent:
                if oldState.hvacState.seats.driverVentCushion != newState.hvacState.seats.driverVentCushion {
                    requestInProgress.remove(.driverSeatVent)
                }
                
                if oldState.hvacState.seats.driverVentBackrest != newState.hvacState.seats.driverVentBackrest {
                    requestInProgress.remove(.driverSeatVent)
                }
            case .passengerSeatHeat:
                if oldState.hvacState.seats.frontPassengerHeatBackrestZone1 != newState.hvacState.seats.frontPassengerHeatBackrestZone1 {
                    requestInProgress.remove(.passengerSeatHeat)
                }
                
                if oldState.hvacState.seats.frontPassengerHeatBackrestZone3 != newState.hvacState.seats.frontPassengerHeatBackrestZone3 {
                    requestInProgress.remove(.passengerSeatHeat)
                }
                
                if oldState.hvacState.seats.frontPassengerHeatCushionZone2 != newState.hvacState.seats.frontPassengerHeatCushionZone2 {
                    requestInProgress.remove(.passengerSeatHeat)
                }
                
                if oldState.hvacState.seats.frontPassengerHeatCushionZone4 != newState.hvacState.seats.frontPassengerHeatCushionZone4 {
                    requestInProgress.remove(.passengerSeatHeat)
                }
            case .passengerSeatVent:
                if oldState.hvacState.seats.frontPassengerVentCushion != newState.hvacState.seats.frontPassengerVentCushion {
                    requestInProgress.remove(.passengerSeatVent)
                }
                
                if oldState.hvacState.seats.frontPassengerVentBackrest != newState.hvacState.seats.frontPassengerVentBackrest {
                    requestInProgress.remove(.passengerSeatVent)
                }
            case .rearLeftSeatHeat:
                if oldState.hvacState.seats.rearPassengerHeatLeft != newState.hvacState.seats.rearPassengerHeatLeft {
                    requestInProgress.remove(.rearLeftSeatHeat)
                }
            case .rearCenterSeatHeat:
                if oldState.hvacState.seats.rearPassengerHeatCenter != newState.hvacState.seats.rearPassengerHeatCenter {
                    requestInProgress.remove(.rearCenterSeatHeat)
                }
            case .rearRightSeatHeat:
                if oldState.hvacState.seats.rearPassengerHeatRight != newState.hvacState.seats.rearPassengerHeatRight {
                    requestInProgress.remove(.rearRightSeatHeat)
                }
            }
        }
        
        Task {
            try? await Task.sleep(for: .seconds(5))
            ogRequestInProgress.forEach { controlType in
                requestInProgress.remove(controlType)
            }
        }
    }
    
    func setSeatClimate(seats: [SeatAssignment]) {
        // Add the new seats to the queue
        seatClimateQueue.append(contentsOf: seats)
        
        // Start processing the queue if we're not already
        Task { [weak self] in
            await self?.processSeatClimateQueue()
        }
    }
    
    private func processSeatClimateQueue() async {
        // If we're already processing or the queue is empty, return
        guard !isProcessingSeatClimateQueue, !seatClimateQueue.isEmpty else { return }
        
        isProcessingSeatClimateQueue = true
        defer { isProcessingSeatClimateQueue = false }
        
        // Get the current batch of seats to process
        let seatsToProcess = seatClimateQueue
        seatClimateQueue.removeAll()
        
        do {
            // Wait a short moment to allow for more seats to be queued
            try await Task.sleep(for: .milliseconds(100))
            
            // If more seats were added while we were waiting, add them back to the queue
            if !seatClimateQueue.isEmpty {
                seatClimateQueue.insert(contentsOf: seatsToProcess, at: 0)
                return
            }
            
            if !vehicleIsReady {
                let _ = try await BearAPI.wakeUp()
            }
            
            seatsToProcess.forEach { seatAssignment in
                switch seatAssignment {
                case .driverHeatBackrestZone1:
                    requestInProgress.insert(.driverSeatHeat)
                case .driverHeatBackrestZone3:
                    requestInProgress.insert(.driverSeatHeat)
                case .driverHeatCushionZone2:
                    requestInProgress.insert(.driverSeatHeat)
                case .driverHeatCushionZone4:
                    requestInProgress.insert(.driverSeatHeat)
                case .driverVentBackrest:
                    requestInProgress.insert(.driverSeatVent)
                case .driverVentCushion:
                    requestInProgress.insert(.driverSeatVent)
                case .frontPassengerHeatBackrestZone1:
                    requestInProgress.insert(.passengerSeatHeat)
                case .frontPassengerHeatBackrestZone3:
                    requestInProgress.insert(.passengerSeatHeat)
                case .frontPassengerHeatCushionZone2:
                    requestInProgress.insert(.passengerSeatHeat)
                case .frontPassengerHeatCushionZone4:
                    requestInProgress.insert(.passengerSeatHeat)
                case .frontPassengerVentBackrest:
                    requestInProgress.insert(.passengerSeatVent)
                case .frontPassengerVentCushion:
                    requestInProgress.insert(.passengerSeatVent)
                case .rearPassengerHeatLeft:
                    requestInProgress.insert(.rearLeftSeatHeat)
                case .rearPassengerHeatCenter:
                    requestInProgress.insert(.rearCenterSeatHeat)
                case .rearPassengerHeatRight:
                    requestInProgress.insert(.rearRightSeatHeat)
                }
            }
            
            let success = try await BearAPI.setSeatClimate(seats: seatsToProcess)
            if !success {
                // put up an alert
            }
            
            // If more seats were added while we were processing, process them
            if !seatClimateQueue.isEmpty {
                await processSeatClimateQueue()
            }
        } catch {
            print("Could not set seat climate: \(error)")
            // If there was an error, put the seats back in the queue to try again
            seatClimateQueue.insert(contentsOf: seatsToProcess, at: 0)
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
}
