//
//  DefrostIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/23/25.
//

import AppIntents

enum DefrostStatus: Int, AppEnum {
    case off
    case on
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Defrost")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct DefrostIntent: AppIntent {
    static var title: LocalizedStringResource = "Defrost"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Power")
    var status: DefrostStatus
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var power: DefrostState = .defrostOff
        
        if self.status == .on {
            power = .defrostOn
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.defrostControl(vehicleID: vehicleID, action: power)
        } else {
            let _ = try await BearAPI.defrostControl(action: power)
        }
        
        return .result()
    }
}
