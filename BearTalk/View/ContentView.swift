//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject private var appState: AppState
    @AppStorage(DefaultsKey.refreshToken) var refreshToken: String = ""

    var homeViewModel: HomeViewModel = HomeViewModel()
    var controlsViewModel: ControlsViewModel = ControlsViewModel()
    var statsViewModel: StatsViewModel = StatsViewModel()
    var mapViewModel: MapViewModel = MapViewModel()
    var rangeViewModel: RangeViewModel = RangeViewModel()

    @State var refreshTimer: Timer?

    var body: some View {
        Group {
            if appState.noCarMode {
                NoCarView()
            } else if appState.appHoldScreen {
                Spacer()
            } else if appState.loggedIn {
                TabView(selection: $appState.selectedTab) {
                    ControlsView(model: controlsViewModel)
                        .tabItem {
                            Image("home")
                            Text("Home")
                        }
                        .tag(AppTab.home)
                    MapView(model: mapViewModel)
                        .tabItem {
                            Image("location")
                            Text("Location")
                        }
                        .tag(AppTab.map)
                    RangeView(model: rangeViewModel)
                        .tabItem {
                            Image("range")
                            Text("Range")
                        }
                        .tag(AppTab.range)
                    StatsView(model: statsViewModel)
                        .tabItem {
                            Image("stats")
                            Text("Stats")
                        }
                        .tag(AppTab.stats)
                }
                .tint(Color(uiColor: .label))
            } else {
                LoginView()
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
        )
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive, .background:
                refreshTimer?.invalidate()
                refreshTimer = nil
            case .active:
                Task {
                    // Check to be sure we have a refresh token. If not, show log in.
                    guard refreshToken.isNotBlank else {
                        appState.appHoldScreen = false
                        return
                    }

                    // Refresh our auth and set a timer to do it again before expiry
                    await refreshAuth()

                    appState.appHoldScreen = false
                }
            @unknown default:
                refreshTimer?.invalidate()
                refreshTimer = nil
            }
        }
    }

    private func refreshAuth() async {
        do {
            let refreshTimeInSec = try await BearAPI.refreshToken()

            if refreshTimeInSec > 0 {
                appState.loggedIn = true
                setRefreshTimer(seconds: refreshTimeInSec - 20)
            }
        } catch let error {
            print("Could not refresh: \(error)")
            appState.appHoldScreen = false
        }
    }

    private func setRefreshTimer(seconds: Int) {
        refreshTimer = Timer
            .scheduledTimer(
                withTimeInterval: TimeInterval(seconds),
                repeats: false,
                block: { _ in
                    Task {
                        await refreshAuth()
                    }
                })
    }
}

#Preview {
    ContentView(controlsViewModel: ControlsViewModel.preview)
        .environmentObject(AppState.preview)
}
