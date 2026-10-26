import AppIntents
import BearTalkProto

enum CreatureComfortStatus: Int, AppEnum {
    case off
    case on

    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Creature Comfort")

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .off: DisplayRepresentation(title: "Off"),
        .on: DisplayRepresentation(title: "On")
    ]
}

struct CreatureComfortIntent: AppIntent {
    static var title: LocalizedStringResource = "Creature Comfort"

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?

    @Parameter(title: "Action")
    var status: CreatureComfortStatus

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicles = try await BearAPI.fetchVehicles()
        let vehicle = vehicles?.first(where: { $0.vehicleId == self.vehicle?.id })
        let mode: Mobilegateway_Protos_CreatureComfortMode = status == .on ? .on : .off

        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setCreatureComfortMode(vehicleID: vehicleID, mode: mode)
        } else {
            let _ = try await BearAPI.setCreatureComfortMode(mode: mode)
        }

        if status == .off {
            let setpointC = vehicle?.vehicleState.hvacState.frontLeftSetTemperature ?? 0
            let celsius = setpointC > 0 ? setpointC : 22
            let temperature = UnitConverter.convertTemperature(
                celsius,
                from: .celsius,
                to: UnitConverter.currentTemperatureUnit
            )

            if let vehicleID = vehicle?.vehicleId {
                let _ = try await BearAPI.setClimateControlState(vehicleID: vehicleID, state: .hvacOff, temperature: temperature)
            } else {
                let _ = try await BearAPI.setClimateControlState(state: .hvacOff, temperature: temperature)
            }
        }

        BearAPI.scheduleWidgetReload()
        return .result()
    }
}
