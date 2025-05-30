//
//  ToggleLockIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/30/25.
//


import AppIntents

enum LockAction: Int, AppEnum {
    case locked
    case unlocked
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Lock Action")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .locked: DisplayRepresentation(title: "Locked"),
        .unlocked: DisplayRepresentation(title: "Unlocked")
    ]
}

struct ToggleLockIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Door Locks"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var action: LockState = .unlocked
        
        if vehicle?.vehicleState.bodyState.doorLocks == .unlocked {
            action = .locked
        }
        
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.doorLockControl(vehicleID: vehicleID, lockState: action)
        } else {
            let _ = try await BearAPI.doorLockControl(lockState: action)
        }
        
        return .result()
    }
}
