//
//  ContentView.swift
//  BearTalkWatch Watch App
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("selectedTab", store: .appGroup) private var selectedTab: Int = 0
    let vehicleViewModel: VehicleViewModel
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                VehicleView(model: vehicleViewModel)
                    .tag(0)
                
                ControlsView(model: vehicleViewModel)
                    .tag(1)
                
                VehicleSwitcherView(container: modelContext.container)
                    .tag(2)
            }
            .tabViewStyle(.verticalPage)
        }
    }
}
