import AppIntents

enum KeylessDrivingStatus: Int, AppEnum {
    case off
    case on

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Keyless Driving")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct KeylessDrivingIntent: AppIntent {
    static var title: LocalizedStringResource = "Keyless Driving"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Action")
    var status: KeylessDrivingStatus

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })

        let enabled = status == .on
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.keylessDrivingControl(vehicleID: vehicleID, enabled: enabled)
        } else {
            let _ = try await BearAPI.keylessDrivingControl(enabled: enabled)
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
