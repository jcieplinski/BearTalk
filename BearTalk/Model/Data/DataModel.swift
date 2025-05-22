//
//  DataModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI
import OSLog

@Observable final class DataModel {
    @ObservationIgnored @AppStorage(DefaultsKey.lastEfficiency) var lastEfficiency: Double = 3.2
    
    var vehicle: Vehicle?
    var refreshTimer: Timer?
    
    // Car Scene
    var selectedModel: CarSceneModel = CarSceneModel.allCases.randomElement() ?? .air
    var showPlatinum: Bool = false
    var showGlassRoof: Bool = true
    var paintColor: PaintColor = .eurekaGold
    var selectedWheel: Wheels = .dream
    var fancyMirrorCaps: Bool = true
    var shouldResetCamera: Bool = false
    
    // Control
    var noVehicleWarning: String = ""
    var powerState: PowerState = .sleep
    var chargePercentage: String = ""
    var exteriorTemp: String = ""
    
    var lockState: LockState?
    var frunkClosureState: DoorState?
    var trunkClosureState: DoorState?
    var chargePortClosureState: DoorState?
    var lightsState: LightAction?
    var defrostState: DefrostState?
    var maxACState: MaxACState?
    var batteryPreConditionState: PreconditioningStatus?
    var climatePowerState: HvacPower?
    var seatClimateState: SeatClimateState?
    var steeringHeaterStatus: SteeringHeaterStatus?
    var gearPosition: GearPosition = .gearUnknown
    var selectedTemperature: Double = Locale.current.measurementSystem == .metric ? 22 : 72
    var seatClimateLevel: Int = 2
    
    // Map
    var gps: GPS?
    
    // Range
    var range: String = ""
    var estimatedRange: String = ""
    var realRange: String = ""
    var kWh: Double = 0.0
    var unitLabel: String = "mi"
    var efficiencyText: String = ""
    var showingEfficiencyPrompt: Bool = false
    
    // Stats
    var nickname: String = ""
    var vin: String = ""
    var year: String = ""
    var model: String = ""
    var trim: String = ""
    var wheels: String = ""
    var odometer: String = ""
    var look: String = ""
    var interior: String = ""
    var interiorTemp: String = ""
    var softwareVersion: String = ""
    var DENumber: String?
    
    var isRefreshing: Bool {
        refreshTimer != nil
    }
    
    var requestInProgress: Set<ControlType> = []
    
    @ObservationIgnored var seatClimateQueue: [SeatAssignment] = []
    @ObservationIgnored var isProcessingSeatClimateQueue = false
    
    var vehicleIsReady: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.powerState {
        case .unknown, .sleep, .sleepCharge, .cloud2, .liveUpdate, .drive:
            return false
        case .monitor, .accessory, .wink, .liveCharge:
            return true
        case .UNRECOGNIZED(_):
            return false
        }
    }
    
    func startRefreshing() {
        if !isRefreshing {
            Task {
                await refreshVehicle()
                setRefreshVehicleTimer()
            }
        }
    }
    
    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func setRefreshVehicleTimer() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshTimer = Timer
                .scheduledTimer(
                    withTimeInterval: TimeInterval(4),
                    repeats: true
                ) { _ in
                    Task { [weak self] in
                        await self?.refreshVehicle()
                    }
                }
        }
    }
    
    private func refreshVehicle() async {
        do {
            let refreshedVehicle = try await BearAPI.fetchCurrentVehicle()
            
            Task { @MainActor in
                resetControlFunction(oldState: vehicle?.vehicleState, newState: refreshedVehicle?.vehicleState)
                vehicle = refreshedVehicle
                gps = refreshedVehicle?.vehicleState.gps
                update()
                updateStats()
                updateRangeStats()
            }
        } catch {
            Logger.vehicle.error("Error updating Vehile: \(error)")
        }
    }
    
    func update() {
        guard let vehicle else { return }
        
        switch vehicle.vehicleConfig.model {
        case .unknown, .UNRECOGNIZED:
            selectedModel = .air
        case .air:
            if vehicle.vehicleConfig.modelVariant == .sapphire {
                selectedModel = .sapphire
            } else {
                selectedModel = .air
            }
        case .gravity:
            selectedModel = .gravity
        }
        
        switch vehicle.vehicleConfig.look {
        case .unknown, .UNRECOGNIZED, .platinum, .surfrider, .base:
            showPlatinum = true
        case .stealth, .sapphire:
            showPlatinum = false
        }
        
        switch vehicle.vehicleConfig.roof {
        case .unknown, .glassCanopy, .UNRECOGNIZED:
            showGlassRoof = true
        case .metal, .carbonFiber:
            showGlassRoof = false
        }
        
        self.selectedWheel = vehicle.vehicleConfig.wheels
        
        switch vehicle.vehicleConfig.modelVariant {
        case .unknown, .UNRECOGNIZED, .touring, .pure:
            fancyMirrorCaps = false
        case .dreamEdition, .grandTouring, .sapphire, .hyper, .executive:
            fancyMirrorCaps = true
        }
        
        gearPosition = vehicle.vehicleState.gearPosition
        
        lockState = vehicle.vehicleState.bodyState.doorLocks
        frunkClosureState = vehicle.vehicleState.bodyState.frontCargo
        trunkClosureState = vehicle.vehicleState.bodyState.rearCargo
        chargePortClosureState = vehicle.vehicleState.bodyState.chargePortState
        lightsState = vehicle.vehicleState.mobileAppReqStatus.lightRequest
        defrostState = vehicle.vehicleState.hvacState.defrost
        maxACState = vehicle.vehicleState.hvacState.maxAcStatus
        batteryPreConditionState = vehicle.vehicleState.batteryState.preconditioningStatus
        climatePowerState = vehicle.vehicleState.hvacState.power
        seatClimateState = vehicle.vehicleState.hvacState.seats
        steeringHeaterStatus = vehicle.vehicleState.hvacState.steeringHeater
        
        powerState = vehicle.vehicleState.powerState
        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"
        
        let exteriorTempMeasurement = Measurement(value: vehicle.vehicleState.cabinState.exteriorTemp, unit: UnitTemperature.celsius)
        let exteriorTempMeasurementConverted = exteriorTempMeasurement.converted(to: UnitTemperature(forLocale: Locale.autoupdatingCurrent))
        
        exteriorTemp = "\(exteriorTempMeasurementConverted.value.rounded()) \(exteriorTempMeasurementConverted.unit.symbol)"
    }
}
