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
    @ObservationIgnored @AppStorage(DefaultsKey.lastEfficiency, store: .appGroup) private var _lastEfficiency: Double = 3.2
    
    // Add a new observable property for the view
    var lastEfficiency: Double {
        get { _lastEfficiency }
        set {
            _lastEfficiency = newValue
            updateRangeStats()  // Update range stats whenever efficiency changes
        }
    }
    
    // Efficiency tracking
    private struct EfficiencyReading {
        let timestamp: Date
        let odometer: Double // in meters
        let batteryLevel: Double // in kWh
    }
    
    @ObservationIgnored private var efficiencyReadings: [EfficiencyReading] = []
    private let maxEfficiencyReadingsAge: TimeInterval = 600 // 10 minutes in seconds
    private let minReadingsForEfficiency = 2 // Need at least 2 readings to calculate efficiency
    
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
    var lightsState: LightState?
    var windowPosition: WindowPosition?
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
    @ObservationIgnored var _estimatedRange: String = ""
    var estimatedRange: String {
        get { _estimatedRange }
        set { _estimatedRange = newValue }
    }
    var realRange: String = ""
    var kWh: Double = 0.0
    var unitLabel: String = "mi"
    var efficiencyText: String = ""
    var showingEfficiencyPrompt: Bool = false
    var isCalculatingEfficiency: Bool = false
    
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
    
    @MainActor
    var requestInProgress: Set<ControlType> = []
    
    @ObservationIgnored var seatClimateQueue: [SeatAssignment] = []
    @ObservationIgnored var isProcessingSeatClimateQueue = false
    
    var vehicleIsReady: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.powerState {
        case .unknown, .sleep, .sleepCharge, .sleepUpdate, .cloud1, .cloud2, .liveUpdate, .drive:
            return false
        case .monitor, .accessory, .wink, .liveCharge:
            return true
        case .UNRECOGNIZED(_):
            return false
        }
    }
    
    // MARK: - Climate Feature Availability
    
    var hasFrontSeatHeating: Bool {
        guard let vehicle else { return false }
        return vehicle.vehicleConfig.frontSeatsHeating == .frontSeatsHeatingAvailable
    }
    
    var hasFrontSeatVentilation: Bool {
        guard let vehicle else { return false }
        return vehicle.vehicleConfig.frontSeatsVentilation == .frontSeatsVentilationAvailable
    }
    
    var hasRearSeatHeating: Bool {
        guard let vehicle else { return false }
        return vehicle.vehicleConfig.secondRowHeatedSeats == .secondRowHeatedSeatsAvailable
    }
    
    var hasSteeringWheelHeat: Bool {
        guard let vehicle else { return false }
        return vehicle.vehicleConfig.heatedSteeringWheel == .heatedSteeringWheelAvailable
    }
    
    @ObservationIgnored private var lastRefreshTime: Date?
    @ObservationIgnored private var refreshCheckTimer: Timer?
    
    func getUserProfile() async throws {
        do {
            // First get the user profile
            userProfile = try await BearAPI.fetchUserProfile()
            
            // Then fetch vehicles with retry
            var retryCount = 0
            let maxRetries = 3
            var lastError: Error?
            
            while retryCount < maxRetries {
                do {
                    // Fetch vehicles and update identifiers
                    if let vehicles = try await BearAPI.fetchVehicles() {
                        // Update vehicle identifiers
                        let vehicleEntities = vehicles.map { vehicle -> VehicleIdentifierEntity in
                            return VehicleIdentifierEntity(id: vehicle.vehicleId, nickname: vehicle.vehicleConfig.nickname)
                        }
                        try await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).add(vehicleEntities)
                        
                        // Update the vehicleIdentifiers property
                        Task { @MainActor in
                            self.vehicleIdentifiers = try? await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).fetch()
                        }
                        
                        // If we have a vehicle ID, try to fetch its current state
                        let vehicleID = BearAPI.vehicleID
                        if vehicleID.isNotBlank {
                            if let currentVehicle = try await BearAPI.fetchCurrentVehicle() {
                                Task { @MainActor in
                                    self.vehicle = currentVehicle
                                    self.update()
                                    self.updateStats()
                                    self.updateRangeStats()
                                }
                            }
                        }
                        return // Success, exit the function
                    }
                } catch let error {
                    Logger.vehicle.error("Vehicle fetch attempt \(retryCount + 1) failed: \(error)")
                    lastError = error
                    
                    // If it's an auth error, try refreshing the token
                    if let rpcError = error as? GRPCCore.RPCError, rpcError.code == .unauthenticated {
                        do {
                            _ = try await BearAPI.refreshToken()
                        } catch {
                            Logger.vehicle.error("Token refresh failed during vehicle fetch: \(error)")
                        }
                    }
                    
                    // Wait before retrying
                    let delay = pow(2.0, Double(retryCount))
                    try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    retryCount += 1
                }
            }
            
            // If we get here, all retries failed
            if let lastError = lastError {
                Logger.vehicle.error("All vehicle fetch attempts failed. Last error: \(lastError)")
                throw lastError
            }
        } catch {
            Logger.vehicle.error("Error in getUserProfile: \(error)")
            throw error
        }
    }
    
    func startRefreshing() {
        if !isRefreshing {
            Task {
                await refreshVehicle()
                setRefreshVehicleTimer()
                startRefreshMonitoring()
                // Prevent device from sleeping while calculating efficiency
                DispatchQueue.main.async {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
            }
        }
    }
    
    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        refreshCheckTimer?.invalidate()
        refreshCheckTimer = nil
        lastRefreshTime = nil
        // Allow device to sleep again when we stop refreshing
        DispatchQueue.main.async {
            UIApplication.shared.isIdleTimerDisabled = false
        }
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
    
    private func startRefreshMonitoring() {
        // Stop any existing monitoring
        refreshCheckTimer?.invalidate()
        
        // Start a timer that checks if we're still refreshing every 10 seconds
        refreshCheckTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if let lastRefresh = self.lastRefreshTime {
                let timeSinceLastRefresh = Date().timeIntervalSince(lastRefresh)
                if timeSinceLastRefresh > 8 { // More than 2 refresh intervals (4s * 2)
                    let message = "🚨 Vehicle refresh appears to have stopped. Last refresh was \(Int(timeSinceLastRefresh))s ago"
                    print(message) // More visible in Xcode debug console
                    Logger.vehicle.error("\(message)")
                }
            }
        }
    }
    
    func refreshVehicle() async {
        do {
            let refreshedVehicle = try await BearAPI.fetchCurrentVehicle()
            lastRefreshTime = Date()
            
            if let vehicle = refreshedVehicle {
                Task { @MainActor in
                    resetControlFunction(oldState: self.vehicle?.vehicleState, newState: vehicle.vehicleState)
                    self.vehicle = vehicle
                    self.gps = vehicle.vehicleState.gps
                    self.update()
                    self.updateStats()
                    self.updateRangeStats()
                    self.updateEfficiency(vehicle: vehicle)
                }
            }
        } catch {
            let message = "Error updating Vehicle: \(error)"
            print("🚨 \(message)") // More visible in Xcode debug console
            Logger.vehicle.error("\(message)")
        }
    }
    
    private func updateEfficiency(vehicle: Vehicle) {
        // Only calculate efficiency if the vehicle is in a state where it's moving
        guard vehicle.vehicleState.powerState == .drive else {
            isCalculatingEfficiency = false
            return
        }
        
        let currentOdometer = vehicle.vehicleState.chassisState.odometerKm  // This is in km
        let currentBattery = vehicle.vehicleState.batteryState.kwHr
        
        // Add new reading
        let newReading = EfficiencyReading(
            timestamp: Date(),
            odometer: currentOdometer,
            batteryLevel: currentBattery
        )
        
        // Add new reading and clean up old ones
        efficiencyReadings.append(newReading)
        efficiencyReadings.removeAll { reading in
            Date().timeIntervalSince(reading.timestamp) > maxEfficiencyReadingsAge
        }
        
        // Need at least 2 readings to calculate efficiency
        guard efficiencyReadings.count >= minReadingsForEfficiency else {
            isCalculatingEfficiency = true
            return
        }
        
        // Get the oldest and newest readings
        let oldestReading = efficiencyReadings.first!
        let newestReading = efficiencyReadings.last!
        
        // Calculate distance traveled in kilometers (odometer is always in km)
        let distanceTraveledKm = newestReading.odometer - oldestReading.odometer
        
        // Calculate energy used in kWh
        let energyUsed = oldestReading.batteryLevel - newestReading.batteryLevel
        
        // Only calculate if we've used energy and moved
        guard energyUsed > 0 && distanceTraveledKm > 0 else {
            isCalculatingEfficiency = true
            return
        }
        
        // Calculate efficiency in km/kWh first (since distance is in km)
        let efficiencyKmPerKWh = distanceTraveledKm / energyUsed
        
        // Convert to miles/kWh if user's locale is imperial
        let calculatedEfficiency: Double
        if Locale.current.measurementSystem == .metric {
            calculatedEfficiency = efficiencyKmPerKWh
        } else {
            // Convert km to miles for imperial users
            let distanceInMiles = distanceTraveledKm * 0.621371  // Convert km to miles
            calculatedEfficiency = distanceInMiles / energyUsed  // Now in miles/kWh
        }
        
        // Update the stored efficiency if it's a reasonable value
        // For metric: typically 4-8 km/kWh
        // For imperial: typically 2.5-5 miles/kWh
        let minEfficiency = Locale.current.measurementSystem == .metric ? 1.0 : 0.6
        let maxEfficiency = Locale.current.measurementSystem == .metric ? 10.0 : 6.2
        
        if calculatedEfficiency >= minEfficiency && calculatedEfficiency <= maxEfficiency {
            _lastEfficiency = calculatedEfficiency
            efficiencyText = String(format: "%.1f", calculatedEfficiency)
            updateRangeStats()
        }
        
        isCalculatingEfficiency = true
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
        lightsState = vehicle.vehicleState.chassisState.headlights
        windowPosition = vehicle.vehicleState.bodyState.windowPosition
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
    
    @Sendable
    func fetchVehicleWithRetry() async {
        do {
            print("Starting profile and vehicle fetch")
            try await getUserProfile()
            
            // Check if we got a vehicle
            if let vehicle = self.vehicle {
                print("Vehicle fetched successfully: \(vehicle.vehicleId)")
                // Only start refreshing if we successfully got the vehicle
                startRefreshing()
            } else {
                print("No vehicle available after profile fetch")
                // Try one more time after a short delay
                print("Waiting 2 seconds before retry")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                print("Retrying profile and vehicle fetch")
                try? await getUserProfile()
                
                if let vehicle = self.vehicle {
                    print("Vehicle fetched successfully on retry: \(vehicle.vehicleId)")
                    startRefreshing()
                } else {
                    print("Still no vehicle after retry")
                    // Check if we have a vehicle ID but failed to fetch
                    if BearAPI.vehicleID.isNotBlank {
                        print("Have vehicleID but failed to fetch vehicle state")
                        // Try one final time with a wake request
                        print("Attempting to wake vehicle")
                        if let wakeSuccess = try? await BearAPI.wakeUp(), wakeSuccess {
                            print("Wake request sent successfully, waiting 5 seconds")
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            print("Final attempt to fetch vehicle")
                            try? await getUserProfile()
                            if self.vehicle != nil {
                                print("Vehicle fetched after wake request")
                                startRefreshing()
                            }
                        } else {
                            print("Wake request failed or returned false")
                        }
                    }
                }
            }
        } catch {
            print("Error fetching profile and vehicles: \(error)")
            // If we get an auth error, try refreshing and fetching again
            if let rpcError = error as? GRPCCore.RPCError, rpcError.code == .unauthenticated {
                print("Auth error during profile fetch, attempting refresh")
                await TokenManager.shared.refreshAuth()
            }
        }
    }
    
    @MainActor
    func uploadProfilePhoto(_ imageData: Data) async throws -> String? {
        let photoURL = try await BearAPI.uploadProfilePhoto(imageData)
        
        // Update the user profile with the new photo URL
        var profile = userProfile
        profile?.photoUrl = photoURL
        userProfile = profile
        
        // Save the photo URL to UserDefaults
        UserDefaults.appGroup.set(photoURL, forKey: DefaultsKey.photoURL)
        
        return photoURL
    }
}
