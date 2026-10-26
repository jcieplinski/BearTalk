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
import SceneKit

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
    
    private struct EfficiencySample: Codable {
        var odometerKm: Double
        var kWh: Double
    }

    private struct EfficiencySegment: Codable {
        var recordedAt: Date
        var distanceKm: Double
        var energyKWh: Double
    }

    private struct EfficiencyLog: Codable {
        var baseline: EfficiencySample?
        var segments: [EfficiencySegment]
    }

    @ObservationIgnored private var efficiencyLogs: [String: EfficiencyLog] = DataModel.loadEfficiencyLogs()
    private let minimumSegmentDistanceKm = 0.5
    private let minimumObservedDistanceKm = 8.0
    private let maximumObservedDistanceKm = 500.0
    private let maximumSegmentAge: TimeInterval = 30 * 24 * 60 * 60
    
    var vehicle: Vehicle?
    var userProfile: UserProfile?
    var refreshTimer: Timer?
    var vehicleIdentifiers: [VehicleIdentifierEntity]?
    
    // Car Scene
    var selectedModel: CarSceneModel = CarSceneModel.allCases.randomElement() ?? .air
    var showPlatinum: Bool = false
    var showGlassRoof: Bool = true
    var paintColor: PaintColor = PaintColor.storedOverride ?? .eurekaGold
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
    var chargePortClosureState: DoorState = .unknown
    var frontLeftDoorClosureState: DoorState = .unknown
    var frontRightDoorClosureState: DoorState = .unknown
    var rearLeftDoorClosureState: DoorState = .unknown
    var rearRightDoorClosureState: DoorState = .unknown
    var lightsState: LightState = .unknown
    var windowPosition: WindowPosition?
    var rideHeight: RideHeight = .unknown
    var keylessDrivingState: KeylessDrivingState = .keylessDrivingUnknown
    var remoteDriveDeadline: Date?
    var remoteDriveSecondsRemaining: Int = 0
    @ObservationIgnored var remoteDriveTimer: Timer?
    @ObservationIgnored var remoteDriveExpiryHandled = false
    var defrostState: DefrostState?
    var maxACState: MaxACState?
    var batteryPreConditionState: PreconditioningStatus?
    var climatePowerState: HvacPower?
    var seatClimateState: SeatClimateState?
    var steeringHeaterStatus: SteeringHeaterStatus?
    var steeringWheelHeatLevel: Int = 2
    var gearPosition: GearPosition = .gearUnknown
    var selectedTemperature: Double = UnitConverter.currentTemperatureUnit == .celsius ? 22 : 72
    var seatClimateLevel: Int = 2
    
    var creatureComfortIsOn: Bool {
        guard let vehicle else { return false }
        let hvacState = vehicle.vehicleState.hvacState
        if hvacState.keepClimateStatus == .petModeOn {
            return true
        }
        
        return hvacState.keepClimateCondition == .keepClimateConditionOnNotOccupied
    }
    
    var keepClimateIsOn: Bool {
        guard let vehicle else { return false }
        let hvacState = vehicle.vehicleState.hvacState
        if hvacState.keepClimateStatus == .petModeOn {
            return false
        }
        
        if hvacState.keepClimateStatus == .enabled {
            return true
        }
        
        return hvacState.keepClimateCondition == .keepClimateConditionOnOccupied
    }
    
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
    @ObservationIgnored private var isPollingEnabled = false
    
    @ObservationIgnored @AppStorage(DefaultsKey.showAlertsBeforeOpenActions, store: .appGroup) var showAlertsBeforeOpenActions: Bool = true
    
    @ObservationIgnored private var hasTakenSnapshots = false
    
    func shouldShowAlertForControl(_ controlType: ControlType) -> Bool {
        guard showAlertsBeforeOpenActions else { return false }
        
        switch controlType {
        case .doorLocks:
            // Only show alert when unlocking
            return lockState == .locked
        case .frunk:
            // Only show alert when opening
            return frunkClosureState == .closed
        case .trunk:
            // Only show alert when opening
            return trunkClosureState == .closed
        case .windows:
            // Only show alert when opening windows
            // For windows, we'll show the alert when the window control sheet is opened
            // since the actual window state is handled in the sheet
            return true
        default:
            return false
        }
    }
    
    func getAlertTitleForControl(_ controlType: ControlType) -> String {
        switch controlType {
        case .doorLocks:
            return "Unlock Doors"
        case .frunk:
            return "Open Frunk"
        case .trunk:
            return "Open Trunk"
        case .windows:
            return "Windows"
        default:
            return ""
        }
    }
    
    func getAlertMessageForControl(_ controlType: ControlType) -> String {
        switch controlType {
        case .doorLocks:
            return "Are you sure you want to unlock the doors?"
        case .frunk:
            return "Are you sure you want to open the frunk?"
        case .trunk:
            return "Are you sure you want to open the trunk?"
        case .windows:
            return "Are you sure you want to open the windows?"
        default:
            return ""
        }
    }
    
    @MainActor
    func takeVehicleSnapshots() async {
        // Only take snapshots once per app launch
        guard !hasTakenSnapshots else { return }
        
        // Get all vehicle identifiers
        guard let vehicleIdentifiers = try? await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).fetch() else {
            return
        }
        
        // For each vehicle, take a snapshot
        for vehicleEntity in vehicleIdentifiers {
            if let vehicle = vehicle, vehicle.vehicleId == vehicleEntity.id {
                let handler = VehicleIdentifierSnapshotHandler(modelContainer: BearAPI.sharedModelContainer)
                try? await handler.takeAndSaveSnapshot(for: vehicle)
            }
        }
        
        hasTakenSnapshots = true
    }
    
    private func updateSnapshotMaterials(in scene: SCNScene, vehicle: Vehicle) {
        // Update car paint color
        let paintUIColor = UIColor(vehicle.vehicleConfig.paintColor.color)
        scene.rootNode.enumerateChildNodes { node, _ in
            if let geometry = node.geometry {
                for material in geometry.materials {
                    if let materialName = material.name?.lowercased() {
                        if materialName.contains("carpaint") || materialName.contains("car_paint") {
                            material.diffuse.contents = paintUIColor
                        }
                    }
                }
            }
        }
        
        // Update wheel visibility
        let wheelNodeName = vehicle.vehicleConfig.wheels.nodeTitle
        scene.rootNode.enumerateChildNodes { node, _ in
            if let nodeName = node.name {
                if vehicle.vehicleConfig.model == .gravity {
                    if nodeName.hasPrefix("Wheel_Set") && 
                       !nodeName.contains("_01_") && 
                       !nodeName.contains("_02_") && 
                       !nodeName.contains("_03_") && 
                       !nodeName.contains("_04_") {
                        node.isHidden = nodeName != wheelNodeName
                    }
                } else {
                    if nodeName.hasPrefix("Wheel_") && 
                       !nodeName.contains("_01_") && 
                       !nodeName.contains("_02_") && 
                       !nodeName.contains("_03_") && 
                       !nodeName.contains("_04_") {
                        node.isHidden = nodeName != wheelNodeName
                    }
                }
            }
        }
        
        // Update platinum/stealth visibility
        let showPlatinum = vehicle.vehicleConfig.look != .stealth && vehicle.vehicleConfig.look != .sapphire
        let showGlassRoof = vehicle.vehicleConfig.roof == .glassCanopy
        
        scene.rootNode.enumerateChildNodes { node, _ in
            if let nodeName = node.name?.lowercased() {
                if nodeName.contains("platinum") {
                    node.isHidden = !showPlatinum
                }
                if nodeName.contains("stealth") {
                    node.isHidden = showPlatinum
                }
                if nodeName.contains("glass") {
                    node.isHidden = !showGlassRoof
                }
                if nodeName.contains("metal") {
                    node.isHidden = showGlassRoof
                }
            }
        }
    }
    
    @MainActor
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
                        let handler = VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer)
                        try await handler.add(vehicleEntities)
                        
                        // Update the vehicleIdentifiers property
                        Task { @MainActor in
                            self.vehicleIdentifiers = try? await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).fetch()
                        }
                        
                        // Take snapshots for all vehicles
                        await takeVehicleSnapshots()
                        
                        // If we have a vehicle ID, try to fetch its current state
                        let vehicleID = BearAPI.vehicleID
                        if vehicleID.isNotBlank {
                            if let currentVehicle = try await BearAPI.fetchCurrentVehicle() {
                                Task { @MainActor in
                                    self.vehicle = currentVehicle
                                    BearAPI.saveWidgetCache(vehicle: currentVehicle)
                                    self.update()
                                    self.updateStats()
                                    self.updateRangeStats()
                                    
                                    // Send vehicle state to watch
                                    await WatchConnectivityManager.shared.sendVehicleStateToWatch()
                                }
                            }
                        }
                        
                        break
                    }
                } catch {
                    lastError = error
                    retryCount += 1
                    if retryCount < maxRetries {
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    }
                }
            }
            
            if retryCount == maxRetries, let error = lastError {
                throw error
            }
        } catch {
            throw error
        }
    }
    
    func startRefreshing() {
        guard isPollingEnabled else { return }
        if !isRefreshing {
            Task { @MainActor in
                await refreshVehicle()
                guard isPollingEnabled else { return }
                setRefreshVehicleTimer()
                startRefreshMonitoring()
                UIApplication.shared.isIdleTimerDisabled = true
            }
        }
    }
    
    func stopRefreshing() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        refreshCheckTimer?.invalidate()
        refreshCheckTimer = nil
        lastRefreshTime = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setRefreshVehicleTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let self, self.isPollingEnabled else { return }
            self.refreshTimer?.invalidate()
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
                guard let self, self.isPollingEnabled else { return }
                Task { await self.refreshVehicle() }
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
                if timeSinceLastRefresh > 16 { // More than 2 refresh intervals (8s * 2)
                    let message = "🚨 Vehicle refresh appears to have stopped. Last refresh was \(Int(timeSinceLastRefresh))s ago"
                    print(message) // More visible in Xcode debug console
                    Logger.vehicle.error("\(message)")
                }
            }
        }
    }

    func setPollingEnabled(_ enabled: Bool) {
        if enabled == isPollingEnabled {
            return
        }
        
        isPollingEnabled = enabled
        if enabled {
            startRefreshing()
        } else {
            stopRefreshing()
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
                    BearAPI.saveWidgetCache(vehicle: vehicle)
                    self.gps = vehicle.vehicleState.gps
                    self.update()
                    self.syncRemoteDriveCountdown()
                    self.updateStats()
                    self.updateRangeStats()
                    self.updateEfficiency(vehicle: vehicle)
                }
                
                // Send vehicle state to watch
                await WatchConnectivityManager.shared.sendVehicleStateToWatch()
            }
        } catch {
            let message = "Error updating Vehicle: \(error)"
            print("🚨 \(message)") // More visible in Xcode debug console
            Logger.vehicle.error("\(message)")
        }
    }
    
    private func updateEfficiency(vehicle: Vehicle) {
        let power = vehicle.vehicleState.powerState
        isCalculatingEfficiency = power == .drive

        let odometerKm = vehicle.vehicleState.chassisState.odometerKm
        let kWh = vehicle.vehicleState.batteryState.kwHr
        guard odometerKm > 0, kWh > 0 else { return }

        let vehicleId = vehicle.vehicleId
        var log = efficiencyLogs[vehicleId] ?? EfficiencyLog(baseline: nil, segments: [])
        let sample = EfficiencySample(odometerKm: odometerKm, kWh: kWh)
        let pluggedIn = isPluggedIn(vehicle.vehicleState.chargingState.chargeState)
            || power == .liveCharge
            || power == .sleepCharge

        if pluggedIn {
            log.baseline = sample
            storeEfficiencyLog(log, for: vehicleId)
            return
        }

        guard let baseline = log.baseline else {
            log.baseline = sample
            storeEfficiencyLog(log, for: vehicleId)
            return
        }

        let distanceKm = odometerKm - baseline.odometerKm
        let energyKWh = baseline.kWh - kWh

        if distanceKm < 0 || energyKWh < 0 {
            log.baseline = sample
            storeEfficiencyLog(log, for: vehicleId)
            return
        }

        guard distanceKm >= minimumSegmentDistanceKm, energyKWh > 0 else { return }

        let usesMetric = Locale.current.measurementSystem == .metric
        let segmentEfficiency = efficiencyValue(distanceKm: distanceKm, energyKWh: energyKWh, usesMetric: usesMetric)
        let minEfficiency = usesMetric ? 1.0 : 0.6
        let maxEfficiency = usesMetric ? 10.0 : 6.2
        guard segmentEfficiency >= minEfficiency, segmentEfficiency <= maxEfficiency else {
            log.baseline = sample
            storeEfficiencyLog(log, for: vehicleId)
            return
        }

        log.segments.append(
            EfficiencySegment(recordedAt: Date(), distanceKm: distanceKm, energyKWh: energyKWh)
        )
        log.baseline = sample
        pruneEfficiencyLog(&log)
        storeEfficiencyLog(log, for: vehicleId)

        let totalDistanceKm = log.segments.reduce(0) { $0 + $1.distanceKm }
        let totalEnergyKWh = log.segments.reduce(0) { $0 + $1.energyKWh }
        guard totalDistanceKm >= minimumObservedDistanceKm, totalEnergyKWh > 0 else { return }

        let observed = efficiencyValue(distanceKm: totalDistanceKm, energyKWh: totalEnergyKWh, usesMetric: usesMetric)
        efficiencyText = String(format: "%.1f", observed)
        lastEfficiency = observed
    }

    static func observedMilesPerKWh(for vehicleId: String) -> Double? {
        guard var log = loadEfficiencyLogs()[vehicleId] else { return nil }
        let cutoff = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        log.segments.removeAll { $0.recordedAt < cutoff }
        let distanceKm = log.segments.reduce(0) { $0 + $1.distanceKm }
        let energyKWh = log.segments.reduce(0) { $0 + $1.energyKWh }
        guard distanceKm > 0, energyKWh > 0 else { return nil }
        return (distanceKm * 0.621371) / energyKWh
    }

    private func isPluggedIn(_ state: ChargeState) -> Bool {
        switch state {
        case .unknown, .notConnected, .UNRECOGNIZED:
            false
        default:
            true
        }
    }

    private func efficiencyValue(distanceKm: Double, energyKWh: Double, usesMetric: Bool) -> Double {
        if usesMetric {
            return distanceKm / energyKWh
        }
        return (distanceKm * 0.621371) / energyKWh
    }

    private func pruneEfficiencyLog(_ log: inout EfficiencyLog) {
        let cutoff = Date().addingTimeInterval(-maximumSegmentAge)
        log.segments.removeAll { $0.recordedAt < cutoff }

        var totalDistanceKm = log.segments.reduce(0) { $0 + $1.distanceKm }
        while totalDistanceKm > maximumObservedDistanceKm, !log.segments.isEmpty {
            totalDistanceKm -= log.segments.removeFirst().distanceKm
        }
    }

    private func storeEfficiencyLog(_ log: EfficiencyLog, for vehicleId: String) {
        efficiencyLogs[vehicleId] = log
        guard let data = try? JSONEncoder().encode(efficiencyLogs) else { return }
        UserDefaults.appGroup.set(data, forKey: DefaultsKey.efficiencyLogs)
    }

    private static func loadEfficiencyLogs() -> [String: EfficiencyLog] {
        guard let data = UserDefaults.appGroup.data(forKey: DefaultsKey.efficiencyLogs),
              let logs = try? JSONDecoder().decode([String: EfficiencyLog].self, from: data) else {
            return [:]
        }
        return logs
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
        frontLeftDoorClosureState = vehicle.vehicleState.bodyState.frontLeftDoor
        frontRightDoorClosureState = vehicle.vehicleState.bodyState.frontRightDoor
        rearLeftDoorClosureState = vehicle.vehicleState.bodyState.rearLeftDoor
        rearRightDoorClosureState = vehicle.vehicleState.bodyState.rearRightDoor
        lightsState = vehicle.vehicleState.chassisState.headlights
        windowPosition = vehicle.vehicleState.bodyState.windowPosition
        rideHeight = vehicle.vehicleState.bodyState.rideHeight
        keylessDrivingState = vehicle.vehicleState.keylessDrivingState
        defrostState = vehicle.vehicleState.hvacState.defrost
        maxACState = vehicle.vehicleState.hvacState.maxAcStatus
        batteryPreConditionState = vehicle.vehicleState.batteryState.preconditioningStatus
        climatePowerState = vehicle.vehicleState.hvacState.power
        seatClimateState = vehicle.vehicleState.hvacState.seats
        steeringHeaterStatus = vehicle.vehicleState.hvacState.steeringHeater
        
        // Set steering wheel heat level from vehicle state
        switch vehicle.vehicleState.hvacState.steeringHeaterLevel {
        case .off, .unknown, .UNRECOGNIZED:
            steeringWheelHeatLevel = 0
        case .steeringWheelHeaterLevel1:
            steeringWheelHeatLevel = 1
        case .steeringWheelHeaterLevel2:
            steeringWheelHeatLevel = 2
        case .steeringWheelHeaterLevel3:
            steeringWheelHeatLevel = 3
        }
        
        powerState = vehicle.vehicleState.powerState
        chargePercentage = "\(vehicle.vehicleState.batteryState.chargePercent.rounded())%"
        
        let currentTempUnit = UnitConverter.currentTemperatureUnit
        let exteriorTempConverted = UnitConverter.convertTemperature(vehicle.vehicleState.cabinState.exteriorTemp, from: .celsius, to: currentTempUnit)
        
        exteriorTemp = UnitConverter.formatTemperature(exteriorTempConverted, unit: currentTempUnit)
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
                if isPollingEnabled {
                    startRefreshing()
                }
            } else {
                print("No vehicle available after profile fetch")
                // Try one more time after a short delay
                print("Waiting 2 seconds before retry")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                print("Retrying profile and vehicle fetch")
                try? await getUserProfile()
                
                if let vehicle = self.vehicle {
                    print("Vehicle fetched successfully on retry: \(vehicle.vehicleId)")
                    if isPollingEnabled {
                        startRefreshing()
                    }
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
                                if isPollingEnabled {
                                    startRefreshing()
                                }
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
