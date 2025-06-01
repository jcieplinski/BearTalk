//
//  FrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

enum OpenAction: Int, AppEnum {
    case close
    case open
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Open Action")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .close: DisplayRepresentation(title: "Close"),
        .open: DisplayRepresentation(title: "Open")
    ]
}

struct FrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Frunk"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Action")
    var action: OpenAction

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var action: DoorState = .closed
        
        if self.action == .open {
            action = .open
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.cargoControl(vehicleID: vehicleID, area: .frunk, closureState: action)
        } else {
            let _ = try await BearAPI.cargoControl(area: .frunk, closureState: action)
        }
        
        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
