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
                .onAppear {
                    // Initialize WatchConnectivity and check for existing credentials
                    let watchConnectivityManager = WatchConnectivityManager.shared
                    
                    // Check for existing application context first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        watchConnectivityManager.checkExistingApplicationContext()
                    }
                    
                    // Request credentials from phone on startup (as backup)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        watchConnectivityManager.requestCredentialsFromPhone()
                    }
                }
        }
    }
}
