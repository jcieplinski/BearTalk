//
//  ContentView.swift
//  BearTalkWatch Watch App
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    let vehicleViewModel: VehicleViewModel
    
    var body: some View {
        TabView {
            VehicleView(model: vehicleViewModel)
        }
        .tabViewStyle(.verticalPage)
    }
}
