//
//  CloseTrunkIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct CloseTrunkIntent: AppIntent {
    static var title: LocalizedStringResource = "Close Trunk"

    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        let _ = try await BearAPI.cargoControl(area: .trunk, closureState: .closed)
        return .result()
    }
}
