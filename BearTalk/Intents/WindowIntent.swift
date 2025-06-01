//
//  WindowIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/27/25.
//

import AppIntents

enum WindowAction: Int, AppEnum {
    case closed
    case open
    case vent
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Window Action")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .closed: DisplayRepresentation(title: "Closed"),
        .open: DisplayRepresentation(title: "Open"),
        .vent: DisplayRepresentation(title: "Vent")
    ]
}

struct WindowIntent: AppIntent {
    static var title: LocalizedStringResource = "Windows"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Action")
    var action: WindowAction
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var state: Mobilegateway_Protos_WindowSwitchState = .autoUpAll
        
        switch self.action {
        case .closed:
            state = .autoUpAll
        case .open:
            state = .autoDownAll
        case .vent:
            state = .ventAll
        }
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.allWindowControl(vehicleID: vehicleID, state: state)
        } else {
            let _ = try await BearAPI.allWindowControl(state: state)
        }
        
        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
