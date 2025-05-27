//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import GRPCCore

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
                    } else if tokenManager.isAppHoldScreen {
                        Spacer()
                    } else if tokenManager.isLoggedIn {
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
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
        )
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
            case .active:
                print("App becoming active")
                tokenManager.logTokenStatus()
                
                Task { @Sendable in
                    await tokenManager.handleAppActivation()
                    if tokenManager.isLoggedIn {
                        model.startRefreshing()
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
