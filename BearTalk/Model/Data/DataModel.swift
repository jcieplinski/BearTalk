//
//  DataModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI
import SwiftData
import OSLog
import GRPCCore

@Observable final class DataModel {
    @ObservationIgnored @AppStorage(DefaultsKey.lastEfficiency, store: .appGroup) var lastEfficiency: Double = 3.2
    
    var vehicle: Vehicle?
    var userProfile: UserProfile?
    var refreshTimer: Timer?
    var vehicleIdentifiers: [VehicleIdentifierEntity]?
    
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
    
    var showingAvailableControls: Bool = false
    
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
    
    func getUserProfile() async throws {
        do {
            print("Starting getUserProfile")
            // First get the user profile
            userProfile = try await BearAPI.fetchUserProfile()
            print("User profile fetched successfully")
            
            // Then fetch vehicles with retry
            var retryCount = 0
            let maxRetries = 3
            var lastError: Error?
            
            while retryCount < maxRetries {
                do {
                    print("Attempting to fetch vehicles (attempt \(retryCount + 1)/\(maxRetries))")
                    // Fetch vehicles and update identifiers
                    if let vehicles = try await BearAPI.fetchVehicles() {
                        print("Successfully fetched \(vehicles.count) vehicles")
                        // Update vehicle identifiers
                        let vehicleEntities = vehicles.map { vehicle -> VehicleIdentifierEntity in
                            return VehicleIdentifierEntity(id: vehicle.vehicleId, nickname: vehicle.vehicleConfig.nickname)
                        }
                        try await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).add(vehicleEntities)
                        print("Updated vehicle identifiers")
                        
                        // If we have a vehicle ID, try to fetch its current state
                        let vehicleID = BearAPI.vehicleID
                        print("Current vehicleID: \(vehicleID)")
                        if vehicleID.isNotBlank {
                            print("Fetching current vehicle state")
                            if let currentVehicle = try await BearAPI.fetchCurrentVehicle() {
                                print("Successfully fetched current vehicle state")
                                Task { @MainActor in
                                    print("Updating vehicle state on main actor")
                                    self.vehicle = currentVehicle
                                    self.update()
                                    self.updateStats()
                                    self.updateRangeStats()
                                    print("Vehicle state update complete")
                                }
                            } else {
                                print("Failed to fetch current vehicle state - no vehicle returned")
                            }
                        } else {
                            print("No vehicleID available, skipping current vehicle fetch")
                        }
                        return // Success, exit the function
                    } else {
                        print("No vehicles returned from fetchVehicles")
                    }
                } catch let error {
                    print("Vehicle fetch attempt \(retryCount + 1) failed: \(error)")
                    lastError = error
                    
                    // If it's an auth error, try refreshing the token
                    if let rpcError = error as? GRPCCore.RPCError, rpcError.code == .unauthenticated {
                        print("Auth error detected, attempting token refresh")
                        do {
                            _ = try await BearAPI.refreshToken()
                            print("Token refresh successful")
                        } catch {
                            print("Token refresh failed during vehicle fetch: \(error)")
                        }
                    }
                    
                    // Wait before retrying
                    let delay = pow(2.0, Double(retryCount))
                    print("Waiting \(delay)s before retry")
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    retryCount += 1
                }
            }
            
            // If we get here, all retries failed
            if let lastError = lastError {
                print("All vehicle fetch attempts failed. Last error: \(lastError)")
                throw lastError
            }
        } catch {
            print("Error in getUserProfile: \(error)")
            throw error
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
    
    func refreshVehicle() async {
        do {
            print("Starting vehicle refresh")
            let refreshedVehicle = try await BearAPI.fetchCurrentVehicle()
            
            if let vehicle = refreshedVehicle {
                print("Successfully refreshed vehicle state")
                Task { @MainActor in
                    print("Updating vehicle state on main actor")
                    resetControlFunction(oldState: self.vehicle?.vehicleState, newState: vehicle.vehicleState)
                    self.vehicle = vehicle
                    self.gps = vehicle.vehicleState.gps
                    self.update()
                    self.updateStats()
                    self.updateRangeStats()
                    print("Vehicle state update complete")
                }
            } else {
                print("No vehicle returned from refresh")
            }
        } catch {
            Logger.vehicle.error("Error updating Vehicle: \(error)")
            print("Error refreshing vehicle: \(error)")
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
