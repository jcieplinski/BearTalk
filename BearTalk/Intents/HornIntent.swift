import AppIntents

struct HornIntent: AppIntent {
    static var title: LocalizedStringResource = "Honk Horn"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })

        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.honkHorn(vehicleID: vehicleID)
        } else {
            let _ = try await BearAPI.honkHorn()
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
