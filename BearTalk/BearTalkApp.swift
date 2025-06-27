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

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
        UITabBar.appearance().unselectedItemTintColor = UIColor.label.withAlphaComponent(0.5)
        
        // Initialize WatchConnectivity
        let _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ColorSchemeWrapper(appState: appState) {
                ContentView()
                    .environment(appState)
                    .environment(dataModel)
                    .tint(.accent)
                    .modelContainer(sharedModelContainer)
            }
        }
    }
}

private struct ColorSchemeWrapper<Content: View>: View {
    @Bindable var colorSchemeManager: ColorSchemeManager = .shared
    let content: Content
    
    init(appState: AppState, @ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .preferredColorScheme(colorSchemeManager.currentScheme)
    }
}
