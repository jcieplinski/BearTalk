//
//  LightsIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/25/23.
//

import AppIntents

enum LightControlAction: Int, AppEnum {
    case on
    case off
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Lights Action")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .on: DisplayRepresentation(title: "On"),
        .off: DisplayRepresentation(title: "Off")
    ]
}

struct LightsIntent: AppIntent {
    static var title: LocalizedStringResource = "Headights"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Action")
    var action: LightControlAction?

    @MainActor func perform() async throws -> some IntentResult {
        var state = LightAction.off
        
        if action == .on {
            state = .on
        }
        
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.lightsControl(action: state)
        
        return .result()
    }
}
