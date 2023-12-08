//
//  OpenFrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import SwiftUI
import AppIntents

struct ToggleFrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Frunk"

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        if let vehicle = try await BearAPI.fetchCurrentVehicle(), let currentClosureState = ClosureState(rawValue: vehicle.vehicleState.bodyState.frontCargo) {
            switch currentClosureState {
            case .open:
                let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .closed)
                return .result(dialog: "Frunk closed")
            case .closed:
                let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .open)
                return .result(dialog: "Frunk open")
            }
        }

        return .result(dialog: "Could not get current frunk state")
    }
}

struct OpenFrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Frunk"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .open)
        return .result()
    }
}

struct CloseFrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Close Frunk"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .frunk, closureState: .closed)
        return .result()
    }
}

struct OpenTrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Trunk"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .trunk, closureState: .open)
        return .result()
    }
}

struct CloseTrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Close Trunk"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .trunk, closureState: .closed)
        return .result()
    }
}

struct UnlockIntent: AppIntent {
    static var title: LocalizedStringResource = "Unlock"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.doorLockControl(lockState: .unlocked)
        return .result()
    }
}

struct LockIntent: AppIntent {
    static var title: LocalizedStringResource = "Lock"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.doorLockControl(lockState: .locked)
        return .result()
    }

}

struct CurrentElevationIntent: AppIntent {
    static var title: LocalizedStringResource = "Elevation"

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchCurrentVehicle()
        let nickname = vehicle?.vehicleConfig.nickname ?? "Your Car"

        if let elevation = vehicle?.vehicleState.gps.elevation {
            let elevationMeasurement = Measurement(value: Double(elevation), unit: UnitLength.centimeters)
            let elevation = elevationMeasurement.formatted(.measurement(width: .abbreviated, usage: .visibility).locale(Locale.autoupdatingCurrent))
            return .result(dialog: IntentDialog(stringLiteral: "\(nickname) is currently at \(elevation)."))
        } else {
            return .result(dialog: IntentDialog(stringLiteral: "Could not get \(nickname)s current elevation."))
        }
    }
}

struct WakeIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Car"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        return .result()
    }
}

struct BearAutoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return  [AppShortcut(intent: OpenFrunkIntent(),
                             phrases: ["Open Frunk with Bear Assist"],
                             shortTitle: "Bear Frunk Open",
                             systemImageName: "car.side.front.open.fill"),
                 AppShortcut(intent: CloseFrunkIntent(),
                             phrases: ["Close Frunk with Bear Assist"],
                             shortTitle: "Bear Frunk Close",
                             systemImageName: "car.side.fill"),
                 AppShortcut(intent: OpenTrunkIntent(),
                             phrases: ["Open Trunk with Bear Assist"],
                             shortTitle: "Bear Trunk Open",
                             systemImageName: "car.side.rear.open.fill"),
                 AppShortcut(intent: CloseTrunkIntent(),
                             phrases: ["Close Trunk with Bear Assist"],
                             shortTitle: "Bear Trunk Close",
                             systemImageName: "car.side.fill"),
                 AppShortcut(intent: UnlockIntent(),
                             phrases: ["Unlock with Bear Assist"],
                             shortTitle: "Bear Unlock",
                             systemImageName: "lock.open.fill"),
                 AppShortcut(intent: LockIntent(),
                             phrases: ["Lock with Bear Assist"],
                             shortTitle: "Bear Lock",
                             systemImageName: "lock.fill"),
                 AppShortcut(intent: CurrentElevationIntent(),
                             phrases: ["Elevation with Bear Assist"],
                             shortTitle: "Elevation",
                             systemImageName: "location.north.circle.fill"),
                 AppShortcut(intent: ToggleFrunkIntent(),
                             phrases: ["Toggle Frunk with Bear Assist"],
                             shortTitle: "Toggle Frunk",
                             systemImageName: "car.side.front.open.fill"),
                 AppShortcut(intent: WakeIntent(),
                             phrases: ["Wake Car with Bear Assist"],
                             shortTitle: "Wake Car",
                             systemImageName: "sunrise.fill")
        ]
    }
}
