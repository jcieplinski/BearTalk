//
//  DoorLockIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
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

struct DoorLockIntent: AppIntent {
    static var title: LocalizedStringResource = "Door Locks"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Action")
    var action: LockAction
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var action: LockState = .locked
        
        if self.action == .unlocked {
            action = .unlocked
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.doorLockControl(vehicleID: vehicleID, lockState: action)
        } else {
            let _ = try await BearAPI.doorLockControl(lockState: action)
        }
        
        return .result()
    }
}
