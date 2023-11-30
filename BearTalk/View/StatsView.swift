//
//  StatsView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var appState: AppState

    @Bindable var model: StatsViewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            List {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Stats")
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

#Preview {
    StatsView(model: StatsViewModel.preview)
        .environmentObject(AppState())
}
