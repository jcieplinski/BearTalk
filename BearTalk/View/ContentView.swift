//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import GRPCCore
import WidgetKit

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(DataModel.self) var model
    @Environment(AppState.self) var appState: AppState
    private let tokenManager = TokenManager.shared
    @State private var isInitializing = true
    
    var body: some View {
        Group {
            @Bindable var appState = appState
            if isInitializing {
                // Show a loading view while we validate the token
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Only show content views after initialization is complete
                Group {
                    if appState.noCarMode {
                        NoCarView()
                    } else if tokenManager.isLoggedIn {
                        if #available(iOS 26.0, *) {
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
                            .tabBarMinimizeBehavior(.onScrollDown)
                            .tint(Color(uiColor: .label))
                        } else {
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
                        }
                    } else {
                        LoginView()
                    }
                }
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
        )
        .overlay {
            ControlAlertView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .handleWatchControlAction)) { notification in
            if let userInfo = notification.userInfo,
               let controlType = userInfo["controlType"] as? ControlType {
                // Handle control action from watch without showing alerts
                model.showAlertsBeforeOpenActions = false
                model.handleControlAction(controlType)
                model.showAlertsBeforeOpenActions = true
            }
        }
        .task {
            // Initialize token manager
            await tokenManager.initialize()
            
            // If we're logged in, start vehicle fetch
            if tokenManager.isLoggedIn {
                Task { @MainActor in
                    await model.fetchVehicleWithRetry()
                }
            }
            
            // Mark initialization as complete
            isInitializing = false
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .inactive, .background:
                print("App entering background/inactive state")
                tokenManager.handleAppBackground()
                model.stopRefreshing()
                WidgetCenter.shared.reloadAllTimelines()
            case .active:
                print("App becoming active")
                tokenManager.logTokenStatus()
                
                // Send credentials to watch when app becomes active
                WatchConnectivityManager.shared.sendCredentialsToWatchIfNeeded()
                
                Task { @Sendable in
                    await tokenManager.handleAppActivation()
                    if tokenManager.isLoggedIn {
                        model.startRefreshing()
                        
                        // Proactively send vehicle state to watch after a short delay
                        try? await Task.sleep(for: .seconds(2.0))
                        await WatchConnectivityManager.shared.sendVehicleStateToWatchIfAvailable()
                    }
                }
            @unknown default:
                model.stopRefreshing()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState.preview)
        .environment(DataModel())
}
