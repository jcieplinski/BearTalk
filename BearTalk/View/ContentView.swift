//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(DataModel.self) var model
    @EnvironmentObject private var appState: AppState
    @AppStorage(DefaultsKey.refreshToken, store: .appGroup) var refreshToken: String = ""
    @AppStorage(DefaultsKey.tokenExpiryTime, store: .appGroup) private var tokenExpiryTime: Double = 0
    
    @State var refreshTimer: Timer?
    @State var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    var body: some View {
        Group {
            if appState.noCarMode {
                NoCarView()
            } else if appState.appHoldScreen {
                Spacer()
            } else if appState.loggedIn {
                TabView(selection: $appState.selectedTab) {
                    ControlsView()
                        .tabItem {
                            Image("home")
                            Text("Home")
                        }
                        .tag(AppTab.home)
                    MapView()
                        .tabItem {
                            Image("location")
                            Text("Location")
                        }
                        .tag(AppTab.map)
                    RangeView()
                        .tabItem {
                            Image("range")
                            Text("Range")
                        }
                        .tag(AppTab.range)
                    StatsView()
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
        .onAppear {
            Task {
                // Check if token is expired or about to expire
                if Date().timeIntervalSince1970 >= tokenExpiryTime - 300 { // 5 minutes before expiry
                    await refreshAuth()
                }
                
                if appState.loggedIn {
                    model.startRefreshing()
                }
                
                try await model.getUserProfile()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive, .background:
                refreshTimer?.invalidate()
                refreshTimer = nil
                
                // Start background task for token refresh
                startBackgroundTask()
                
                model.stopRefreshing()
            case .active:
                // End any background task
                if backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    backgroundTask = .invalid
                }
                
                Task {
                    // Check to be sure we have a refresh token. If not, show log in.
                    guard refreshToken.isNotBlank else {
                        appState.appHoldScreen = false
                        return
                    }
                    
                    // Check if token is expired or about to expire
                    if Date().timeIntervalSince1970 >= tokenExpiryTime - 300 { // 5 minutes before expiry
                        await refreshAuth()
                    }
                    
                    if appState.loggedIn {
                        model.startRefreshing()
                    }
                    
                    appState.appHoldScreen = false
                }
            @unknown default:
                refreshTimer?.invalidate()
                refreshTimer = nil
                
                model.stopRefreshing()
            }
        }
    }
    
    private func startBackgroundTask() {
        // End any existing background task
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        
        // Start new background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
            // Cleanup when background task expires
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
        
        // Schedule background refresh
        Task {
            // Check if we need to refresh before the background task expires
            if Date().timeIntervalSince1970 >= tokenExpiryTime - 300 { // 5 minutes before expiry
                await refreshAuth()
            }
            
            // End background task
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
    }
    
    private func refreshAuth() async {
        do {
            let refreshTimeInSec = try await BearAPI.refreshToken()
            
            if refreshTimeInSec > 0 {
                appState.loggedIn = true
                // Store the expiry time
                tokenExpiryTime = Date().timeIntervalSince1970 + Double(refreshTimeInSec)
                // Set refresh timer to refresh 5 minutes before expiry
                setRefreshTimer(seconds: refreshTimeInSec - 300)
            }
        } catch let error {
            print("Could not refresh: \(error)")
            appState.appHoldScreen = false
            // Clear expiry time on error
            tokenExpiryTime = 0
        }
    }
    
    private func setRefreshTimer(seconds: Int) {
        refreshTimer?.invalidate()
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
    ContentView()
        .environmentObject(AppState.preview)
        .environment(DataModel())
}
