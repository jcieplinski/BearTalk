//
//  BearTalkApp.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

@main
struct BearTalkApp: App {
    var appState: AppState = AppState()
    var dataModel: DataModel = DataModel()

    init() {
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = UIColor(named: "AccentColor")
        UITabBar.appearance().unselectedItemTintColor = UIColor.label.withAlphaComponent(0.18)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environment(dataModel)
                .tint(.accent)
        }
    }
}
