//
//  VehicleViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

@Observable class VehicleViewModel {
  //  @ObservationIgnored @AppStorage(DefaultsKey.vehicleID, store: .appGroup) var vehicleID: String = ""
    
    var nickname: String = ""
    var snapshotData: Data?
    var chargePercent: Double = 0
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
        
        // Set up callback for when credentials are received
        WatchConnectivityManager.shared.onCredentialsReceived = { [weak self] in
            Task { @MainActor in
                await self?.setup()
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
        // Check if we have the required credentials
        let authorization = UserDefaults.appGroup.string(forKey: DefaultsKey.authorization) ?? ""
        let refreshToken = UserDefaults.appGroup.string(forKey: DefaultsKey.refreshToken) ?? ""
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        print("VehicleViewModel: Current credentials - authorization: \(authorization.prefix(10))..., refreshToken: \(refreshToken.prefix(10))..., vehicleID: \(vehicleID)")
        
        // If we don't have credentials, request them from the phone
        if authorization.isEmpty || refreshToken.isEmpty || vehicleID.isEmpty {
            print("VehicleViewModel: Missing credentials, requesting from phone...")
            WatchConnectivityManager.shared.requestCredentialsFromPhone()
            
            // Wait a bit for the credentials to arrive
            try? await Task.sleep(for: .seconds(2))
            
            // Check again after waiting
            let updatedAuthorization = UserDefaults.appGroup.string(forKey: DefaultsKey.authorization) ?? ""
            let updatedRefreshToken = UserDefaults.appGroup.string(forKey: DefaultsKey.refreshToken) ?? ""
            let updatedVehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
            print("VehicleViewModel: After waiting - authorization: \(updatedAuthorization.prefix(10))..., refreshToken: \(updatedRefreshToken.prefix(10))..., vehicleID: \(updatedVehicleID)")
        }
        
        // Try to get credentials again after potential update
        let finalVehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        do {
            let currentVehicleIdentifier = try await VehicleIdentifierHandler(modelContainer: container).fetch()
            let vehicle = currentVehicleIdentifier.first(where: { $0.id == finalVehicleID })
            nickname = vehicle?.nickname ?? ""
            snapshotData = vehicle?.snapshotData
            
            print("VehicleViewModel: Found vehicle with nickname: \(nickname)")
            
            // Only try to fetch vehicle data if we have a vehicleID
            if !finalVehicleID.isEmpty {
                print("VehicleViewModel: Requesting vehicle state from phone for ID: \(finalVehicleID)")
                WatchConnectivityManager.shared.requestVehicleStateFromPhone()
            } else {
                print("VehicleViewModel: No vehicleID available, skipping vehicle state request")
            }
        } catch {
            print("VehicleViewModel: Failed to fetch current vehicle: \(error)")
        }
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
    }
}

// Custom timeout error
struct TimeoutError: Error {
    let message = "Operation timed out"
}
