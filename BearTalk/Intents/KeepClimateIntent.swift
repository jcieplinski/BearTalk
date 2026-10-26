import AppIntents

enum KeepClimateAction: Int, AppEnum {
    case off
    case on

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Keep Climate")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct KeepClimateIntent: AppIntent {
    static var title: LocalizedStringResource = "Keep Climate"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Action")
    var status: KeepClimateAction

    @Parameter(title: "Temperature")
    var temperature: Double

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        let power: HvacPower = status == .on ? .hvacKeepTemp : .hvacOff

        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setClimateControlState(vehicleID: vehicleID, state: power, temperature: temperature)
        } else {
            let _ = try await BearAPI.setClimateControlState(state: power, temperature: temperature)
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
