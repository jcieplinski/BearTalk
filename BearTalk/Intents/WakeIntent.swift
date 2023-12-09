//
//  WakeIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct WakeIntent: AppIntent {
    static var title: LocalizedStringResource = "Wake Car"

    @MainActor func perform() async throws -> some ProvidesDialog {
        let _ = try await BearAPI.refreshToken()
        let _ = try await BearAPI.wakeUp()
        return .result(dialog: "Waking Car…")
    }
}
