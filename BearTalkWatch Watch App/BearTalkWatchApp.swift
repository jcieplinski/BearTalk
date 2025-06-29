//
//  BearTalkWatchApp.swift
//  BearTalkWatch Watch App
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

@main
struct BearTalkWatch_Watch_AppApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VehicleIdentifier.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            groupContainer: .identifier("group.com.joecieplinski.bearTalk"),
            cloudKitDatabase: .private("iCloud.com.joecieplinski.bearTalkTwo")
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(vehicleViewModel: VehicleViewModel(container: sharedModelContainer))
                .tint(.accent)
                .modelContainer(sharedModelContainer)
                .task {
                    // Remove duplicate vehicles on startup
                    do {
                        let handler = VehicleIdentifierHandler(modelContainer: sharedModelContainer)
                        try await handler.removeDuplicates()
                    } catch {
                        print("Failed to remove duplicate vehicles: \(error)")
                    }
                }
                .onAppear {
                    // Initialize WatchConnectivity and set up communication
                    let watchConnectivityManager = WatchConnectivityManager.shared
                    
                    // Log session state for debugging
                    watchConnectivityManager.logSessionState()
                    
                    // Check for existing application context first (immediate)
                    watchConnectivityManager.checkExistingApplicationContext()
                    
                    // Request credentials from phone after a short delay (as backup)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        watchConnectivityManager.requestCredentialsFromPhone()
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    switch newPhase {
                    case .active:
                        print("Watch app becoming active")
                        // Request fresh vehicle state when app becomes active
                        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
                        if !vehicleID.isEmpty {
                            print("Watch app: App became active, requesting vehicle state")
                            WatchConnectivityManager.shared.requestVehicleStateFromPhone()
                        }
                    case .inactive, .background:
                        print("Watch app entering background/inactive")
                    @unknown default:
                        break
                    }
                }
        }
    }
}
