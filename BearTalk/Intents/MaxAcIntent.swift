//
//  MaxAcIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/23/25.
//

import AppIntents

enum MaxAxStatus: Int, AppEnum {
    case off
    case on
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Max AC")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct MaxAcIntent: AppIntent {
    static var title: LocalizedStringResource = "Max AC"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Power")
    var status: MaxAxStatus
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var power: MaxACState = .off
        
        if self.status == .on {
            power = .on
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setMaxAC(vehicleID: vehicleID, state: power)
        } else {
            let _ = try await BearAPI.setMaxAC(state: power)
        }
        
        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
