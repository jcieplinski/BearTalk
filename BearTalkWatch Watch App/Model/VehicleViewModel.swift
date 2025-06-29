//
//  VehicleViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

@Observable class VehicleViewModel {
    var nickname: String = ""
    var snapshotData: Data?
    var chargePercent: Double = 0
    var container: ModelContainer
    
    // Vehicle state properties for control buttons
    var lockState: LockState = .unknown
    var frunkClosureState: DoorState = .unknown
    var trunkClosureState: DoorState = .unknown
    var chargePortClosureState: DoorState = .unknown
    var lightsState: LightState = .unknown
    var windowPosition: WindowPosition?
    var defrostState: DefrostState?
    var maxACState: MaxACState?
    var batteryPreConditionState: PreconditioningStatus?
    var climatePowerState: HvacPower?
    var seatClimateState: SeatClimateState?
    var steeringHeaterStatus: SteeringHeaterStatus?
    
    // Sync state tracking
    private var isSetupComplete = false
    private var lastSyncAttempt: Date?
    private var syncRetryCount = 0
    private let maxSyncRetries = 3
    private let syncRetryDelay: TimeInterval = 2.0
    
    init(container: ModelContainer) {
        self.container = container
        
        // Set up callback for when credentials are received
        WatchConnectivityManager.shared.onCredentialsReceived = { [weak self] in
            Task { @MainActor in
                await self?.handleCredentialsReceived()
            }
        }
        
        // Set up callback for when vehicle state is received
        WatchConnectivityManager.shared.onVehicleStateReceived = { [weak self] vehicleStateData in
            Task { @MainActor in
                await self?.handleVehicleStateUpdate(vehicleStateData)
            }
        }
    }
    
    func setup() async {
        print("VehicleViewModel: Starting setup process")
        
        // Check if we already have valid credentials
        let hasValidCredentials = await checkCredentials()
        
        if hasValidCredentials {
            print("VehicleViewModel: Found valid credentials, proceeding with setup")
            await loadVehicleData()
            await requestVehicleState()
        } else {
            print("VehicleViewModel: No valid credentials, requesting from phone")
            await requestCredentialsWithRetry()
        }
        
        isSetupComplete = true
    }
    
    private func checkCredentials() async -> Bool {
        let authorization = UserDefaults.appGroup.string(forKey: DefaultsKey.authorization) ?? ""
        let refreshToken = UserDefaults.appGroup.string(forKey: DefaultsKey.refreshToken) ?? ""
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        print("VehicleViewModel: Checking credentials - authorization: \(authorization.prefix(10))..., refreshToken: \(refreshToken.prefix(10))..., vehicleID: \(vehicleID)")
        
        return !authorization.isEmpty && !refreshToken.isEmpty && !vehicleID.isEmpty
    }
    
    private func requestCredentialsWithRetry() async {
        syncRetryCount = 0
        
        while syncRetryCount < maxSyncRetries {
            print("VehicleViewModel: Requesting credentials from phone (attempt \(syncRetryCount + 1)/\(maxSyncRetries))")
            
            WatchConnectivityManager.shared.requestCredentialsFromPhone()
            
            // Wait for credentials to arrive
            try? await Task.sleep(for: .seconds(syncRetryDelay))
            
            // Check if we received credentials
            if await checkCredentials() {
                print("VehicleViewModel: Successfully received credentials")
                await loadVehicleData()
                await requestVehicleState()
                return
            }
            
            syncRetryCount += 1
            
            if syncRetryCount < maxSyncRetries {
                print("VehicleViewModel: Credentials not received, retrying in \(syncRetryDelay) seconds")
                try? await Task.sleep(for: .seconds(syncRetryDelay))
            }
        }
        
        print("VehicleViewModel: Failed to receive credentials after \(maxSyncRetries) attempts")
    }
    
    private func handleCredentialsReceived() async {
        print("VehicleViewModel: Credentials received callback triggered")
        
        if !isSetupComplete {
            // If setup isn't complete, continue with the setup process
            await loadVehicleData()
            await requestVehicleState()
        } else {
            // If setup is complete, just request fresh vehicle state
            await requestVehicleState()
        }
    }
    
    private func loadVehicleData() async {
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        do {
            let currentVehicleIdentifier = try await VehicleIdentifierHandler(modelContainer: container).fetch()
            let vehicle = currentVehicleIdentifier.first(where: { $0.id == vehicleID })
            
            if let vehicle = vehicle {
                nickname = vehicle.nickname
                snapshotData = vehicle.snapshotData
                print("VehicleViewModel: Loaded vehicle data for '\(nickname)'")
            } else {
                print("VehicleViewModel: No vehicle found for ID: \(vehicleID)")
            }
        } catch {
            print("VehicleViewModel: Failed to load vehicle data: \(error)")
        }
    }
    
    private func requestVehicleState() async {
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        if vehicleID.isEmpty {
            print("VehicleViewModel: No vehicleID available, cannot request vehicle state")
            return
        }
        
        print("VehicleViewModel: Requesting vehicle state from phone for ID: \(vehicleID)")
        WatchConnectivityManager.shared.requestVehicleStateFromPhone()
        
        // Set a timeout for the vehicle state request
        Task {
            try? await Task.sleep(for: .seconds(5.0))
            
            // If we still don't have charge percent data after 5 seconds, try again
            if chargePercent == 0 {
                print("VehicleViewModel: Vehicle state request timed out, retrying...")
                await requestVehicleStateWithRetry()
            }
        }
    }
    
    private func requestVehicleStateWithRetry() async {
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        if vehicleID.isEmpty {
            return
        }
        
        var retryCount = 0
        let maxRetries = 2
        
        while retryCount < maxRetries {
            print("VehicleViewModel: Retrying vehicle state request (attempt \(retryCount + 1)/\(maxRetries))")
            
            WatchConnectivityManager.shared.requestVehicleStateFromPhone()
            
            // Wait for response
            try? await Task.sleep(for: .seconds(3.0))
            
            // If we received data, break
            if chargePercent > 0 || nickname.isNotBlank {
                print("VehicleViewModel: Successfully received vehicle state on retry")
                break
            }
            
            retryCount += 1
            
            if retryCount < maxRetries {
                try? await Task.sleep(for: .seconds(2.0))
            }
        }
        
        if retryCount == maxRetries {
            print("VehicleViewModel: Failed to receive vehicle state after \(maxRetries) retries")
        }
    }
    
    // Manual refresh function that can be called by the user
    func refreshVehicleState() async {
        print("VehicleViewModel: Manual refresh requested")
        await requestVehicleState()
    }
    
    @MainActor
    func handleVehicleStateUpdate(_ vehicleStateData: [String: Any]) async {
        print("VehicleViewModel: Handling vehicle state update: \(vehicleStateData)")
        
        // Extract vehicle state data
        if let chargePercentValue = vehicleStateData["chargePercent"] as? Double {
            chargePercent = chargePercentValue
            print("VehicleViewModel: Updated chargePercent: \(chargePercent)")
        }
        
        if let nicknameValue = vehicleStateData["nickname"] as? String {
            nickname = nicknameValue
            print("VehicleViewModel: Updated nickname: \(nickname)")
        }
        
        // Extract control state data using appropriate initializers
        if let lockStateValue = vehicleStateData["lockState"] as? Int {
            lockState = LockState(intValue: lockStateValue)
        }
        
        if let frunkStateValue = vehicleStateData["frunkClosureState"] as? Int {
            frunkClosureState = doorStateFromInt(frunkStateValue)
        }
        
        if let trunkStateValue = vehicleStateData["trunkClosureState"] as? Int {
            trunkClosureState = doorStateFromInt(trunkStateValue)
        }
        
        if let chargePortStateValue = vehicleStateData["chargePortClosureState"] as? Int {
            chargePortClosureState = doorStateFromInt(chargePortStateValue)
        }
        
        if let lightsStateValue = vehicleStateData["lightsState"] as? Int {
            lightsState = lightStateFromInt(lightsStateValue)
        }
        
        if let defrostStateValue = vehicleStateData["defrostState"] as? Int {
            defrostState = defrostStateFromInt(defrostStateValue)
        }
        
        if let maxACStateValue = vehicleStateData["maxACState"] as? Int {
            maxACState = maxACStateFromInt(maxACStateValue)
        }
        
        if let batteryPreConditionStateValue = vehicleStateData["batteryPreConditionState"] as? Int {
            batteryPreConditionState = preconditioningStatusFromInt(batteryPreConditionStateValue)
        }
        
        if let climatePowerStateValue = vehicleStateData["climatePowerState"] as? Int {
            climatePowerState = hvacPowerFromInt(climatePowerStateValue)
        }
        
        if let steeringHeaterStatusValue = vehicleStateData["steeringHeaterStatus"] as? Int {
            steeringHeaterStatus = steeringHeaterStatusFromInt(steeringHeaterStatusValue)
        }
        
        // Handle window position (complex object)
        if let windowData = vehicleStateData["windowPosition"] as? [String: Any] {
            let leftFront = windowPositionStatusFromInt(windowData["leftFront"] as? Int ?? 0)
            let leftRear = windowPositionStatusFromInt(windowData["leftRear"] as? Int ?? 0)
            let rightFront = windowPositionStatusFromInt(windowData["rightFront"] as? Int ?? 0)
            let rightRear = windowPositionStatusFromInt(windowData["rightRear"] as? Int ?? 0)
            
            windowPosition = WindowPosition(
                leftFront: leftFront,
                leftRear: leftRear,
                rightFront: rightFront,
                rightRear: rightRear
            )
        }
        
        // Handle seat climate state (complex object)
        if let seatClimateData = vehicleStateData["seatClimateState"] as? [String: Any] {
            let driverHeatBackrestZone1 = seatClimateModeFromInt(seatClimateData["driverHeatBackrestZone1"] as? Int ?? 0)
            let driverHeatBackrestZone3 = seatClimateModeFromInt(seatClimateData["driverHeatBackrestZone3"] as? Int ?? 0)
            let driverHeatCushionZone2 = seatClimateModeFromInt(seatClimateData["driverHeatCushionZone2"] as? Int ?? 0)
            let driverHeatCushionZone4 = seatClimateModeFromInt(seatClimateData["driverHeatCushionZone4"] as? Int ?? 0)
            let driverVentBackrest = seatClimateModeFromInt(seatClimateData["driverVentBackrest"] as? Int ?? 0)
            let driverVentCushion = seatClimateModeFromInt(seatClimateData["driverVentCushion"] as? Int ?? 0)
            let frontPassengerHeatBackrestZone1 = seatClimateModeFromInt(seatClimateData["frontPassengerHeatBackrestZone1"] as? Int ?? 0)
            let frontPassengerHeatBackrestZone3 = seatClimateModeFromInt(seatClimateData["frontPassengerHeatBackrestZone3"] as? Int ?? 0)
            let frontPassengerHeatCushionZone2 = seatClimateModeFromInt(seatClimateData["frontPassengerHeatCushionZone2"] as? Int ?? 0)
            let frontPassengerHeatCushionZone4 = seatClimateModeFromInt(seatClimateData["frontPassengerHeatCushionZone4"] as? Int ?? 0)
            let frontPassengerVentBackrest = seatClimateModeFromInt(seatClimateData["frontPassengerVentBackrest"] as? Int ?? 0)
            let frontPassengerVentCushion = seatClimateModeFromInt(seatClimateData["frontPassengerVentCushion"] as? Int ?? 0)
            let rearPassengerHeatLeft = seatClimateModeFromInt(seatClimateData["rearPassengerHeatLeft"] as? Int ?? 0)
            let rearPassengerHeatCenter = seatClimateModeFromInt(seatClimateData["rearPassengerHeatCenter"] as? Int ?? 0)
            let rearPassengerHeatRight = seatClimateModeFromInt(seatClimateData["rearPassengerHeatRight"] as? Int ?? 0)
            
            seatClimateState = SeatClimateState(
                driverHeatBackrestZone1: driverHeatBackrestZone1,
                driverHeatBackrestZone3: driverHeatBackrestZone3,
                driverHeatCushionZone2: driverHeatCushionZone2,
                driverHeatCushionZone4: driverHeatCushionZone4,
                driverVentBackrest: driverVentBackrest,
                driverVentCushion: driverVentCushion,
                frontPassengerHeatBackrestZone1: frontPassengerHeatBackrestZone1,
                frontPassengerHeatBackrestZone3: frontPassengerHeatBackrestZone3,
                frontPassengerHeatCushionZone2: frontPassengerHeatCushionZone2,
                frontPassengerHeatCushionZone4: frontPassengerHeatCushionZone4,
                frontPassengerVentBackrest: frontPassengerVentBackrest,
                frontPassengerVentCushion: frontPassengerVentCushion,
                rearPassengerHeatLeft: rearPassengerHeatLeft,
                rearPassengerHeatCenter: rearPassengerHeatCenter,
                rearPassengerHeatRight: rearPassengerHeatRight
            )
        }
        
        // Update last sync time
        lastSyncAttempt = Date()
        syncRetryCount = 0
    }
    
    // Helper functions to create enum instances from integer values
    private func doorStateFromInt(_ intValue: Int) -> DoorState {
        switch intValue {
        case 0: return .unknown
        case 1: return .open
        case 2: return .closed
        case 3: return .ajar
        case 4: return .closeError
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func lightStateFromInt(_ intValue: Int) -> LightState {
        switch intValue {
        case 0: return .unknown
        case 1: return .flash
        case 2: return .on
        case 3: return .off
        case 4: return .hazardOn
        case 5: return .hazardOff
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func defrostStateFromInt(_ intValue: Int) -> DefrostState {
        switch intValue {
        case 0: return .unknown
        case 1: return .defrostOn
        case 2: return .defrostOff
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func maxACStateFromInt(_ intValue: Int) -> MaxACState {
        switch intValue {
        case 0: return .unknown
        case 1: return .off
        case 2: return .on
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func preconditioningStatusFromInt(_ intValue: Int) -> PreconditioningStatus {
        switch intValue {
        case 0: return .batteryPreconUnknown
        case 1: return .batteryPreconOff
        case 2: return .batteryPreconOn
        case 3: return .batteryPreconUnavailable
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func hvacPowerFromInt(_ intValue: Int) -> HvacPower {
        switch intValue {
        case 0: return .unknown
        case 1: return .hvacOn
        case 2: return .hvacOff
        case 3: return .hvacPrecondition
        case 5: return .hvacResidualHeating
        case 6: return .hvacKeepTemp
        case 7: return .hvacHeatstrokePrevention
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func steeringHeaterStatusFromInt(_ intValue: Int) -> SteeringHeaterStatus {
        switch intValue {
        case 0: return .unknown
        case 1: return .off
        case 2: return .on
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func windowPositionStatusFromInt(_ intValue: Int) -> WindowPositionStatus {
        switch intValue {
        case 0: return .unknown
        case 1: return .fullyClosed
        case 2: return .aboveShortDropPosition
        case 3: return .shortDropPosition
        case 4: return .belowShortDropPosition
        case 5: return .fullyOpen
        case 6: return .unknownDeInitialized
        case 7: return .atpReversePosition
        case 8: return .anticlatterPosition
        case 9: return .hardStopUp
        case 10: return .hardStopDown
        case 11: return .longDropPosition
        case 12: return .ventDropPosition
        case 13: return .betweenFullyClosedAndShortDropDown
        case 14: return .betweenShortDropDownAndFullyOpen
        default: return .UNRECOGNIZED(intValue)
        }
    }
    
    private func seatClimateModeFromInt(_ intValue: Int) -> SeatClimateMode {
        switch intValue {
        case 0: return .unknown
        case 2: return .off
        case 3: return .low
        case 4: return .medium
        case 5: return .high
        default: return .UNRECOGNIZED(intValue)
        }
    }
}

// Custom timeout error
struct TimeoutError: Error {
    let message = "Operation timed out"
}
