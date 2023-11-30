//
//  StatsView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

struct StatsView: View {
    @EnvironmentObject private var appState: AppState

    @Bindable var model: StatsViewModel

    var body: some View {
        NavigationStack {
            List {
                Section("Car") {
                    StatsCell(title: "Vehicle", stat: model.nickname)
                    StatsCell(title: "Vin", stat: model.vin)
                    StatsCell(title: "Year", stat: model.year)
                    StatsCell(title: "Model", stat: model.model)
                    StatsCell(title: "Trim", stat: model.trim)
                }

                Section("Status") {
                    StatsCell(title: "Odometer", stat: model.odometer)
                    StatsCell(title: "Software Version", stat: model.softwareVersion)
                }

                Section("Battery") {
                    StatsCell(title: "Charge Percentage", stat: model.chargePercentage)
                    StatsCell(title: "Range", stat: model.range)
                }

                Section("Temperature") {
                    StatsCell(title: "Interior Temp", stat: model.interiorTemp)
                    StatsCell(title: "Exterior Temp", stat: model.exteriorTemp)
                }

                Section("Configuration") {
                    StatsCell(title: "Color", stat: model.paintColor)
                    StatsCell(title: "Interior", stat: model.interior)
                    StatsCell(title: "Look", stat: model.look)
                    StatsCell(title: "Wheels", stat: model.wheels)
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Stats")
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
            .task {
                await model.fetchVehicle()
            }
        }
    }
}

#Preview {
    StatsView(model: StatsViewModel.preview)
        .environmentObject(AppState())
}
