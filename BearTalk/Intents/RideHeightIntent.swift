import AppIntents

enum RideHeightLevel: Int, AppEnum {
    case highest
    case high
    case standard
    case low
    case lowest

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Ride Height")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .highest: DisplayRepresentation(title: "Highest"),
        .high: DisplayRepresentation(title: "High"),
        .standard: DisplayRepresentation(title: "Standard"),
        .low: DisplayRepresentation(title: "Low"),
        .lowest: DisplayRepresentation(title: "Lowest")
    ]

    var height: RideHeight {
        switch self {
        case .highest: .highest
        case .high: .high
        case .standard: .standard
        case .low: .low
        case .lowest: .lowest
        }
    }
}

struct RideHeightIntent: AppIntent {
    static var title: LocalizedStringResource = "Ride Height"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Height")
    var height: RideHeightLevel

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })

        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.rideHeightControl(vehicleID: vehicleID, target: height.height)
        } else {
            let _ = try await BearAPI.rideHeightControl(target: height.height)
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
