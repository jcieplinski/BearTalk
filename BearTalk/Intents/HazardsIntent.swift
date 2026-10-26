import AppIntents

enum HazardStatus: Int, AppEnum {
    case off
    case on

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Hazards")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct HazardsIntent: AppIntent {
    static var title: LocalizedStringResource = "Hazard Lights"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Action")
    var status: HazardStatus

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        let action: LightAction = status == .on ? .hazardOn : .hazardOff

        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.lightsControl(vehicleID: vehicleID, action: action)
        } else {
            let _ = try await BearAPI.lightsControl(action: action)
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
