//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    @AppStorage(DefaultsKey.refreshToken) var refreshToken: String = ""

    var body: some View {
        Group {
            if appState.appHoldScreen {
                EmptyView()
            } else if appState.loggedIn {
                HomeView()
            } else {
                LoginView()
            }
        }
        .task {
            do {
                guard refreshToken.isNotBlank else {
                    appState.appHoldScreen = false
                    return
                }
                let logInCheck = try await BearAPI.refreshToken()
                if logInCheck {
                    appState.loggedIn = true
                }

                appState.appHoldScreen = false
            } catch let error {
                print("Could not refresh: \(error)")
                appState.appHoldScreen = false
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}
