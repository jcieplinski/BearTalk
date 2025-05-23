//
//  BearTalkApp.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import SwiftData

@main
struct BearTalkApp: App {
    var appState: AppState = AppState()
    var dataModel: DataModel = DataModel()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VehicleIdentifier.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
        UITabBar.appearance().unselectedItemTintColor = UIColor.label.withAlphaComponent(0.5)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(dataModel)
                .tint(.accent)
                .modelContainer(sharedModelContainer)
        }
    }
}
