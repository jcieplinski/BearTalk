//
//  StatsView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI
import MessageUI

struct StatsView: View {
    @EnvironmentObject private var appState: AppState

    @Bindable var model: StatsViewModel

    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var showingMailView = false
    @State var showingMailWarning: Bool = false
    @State var vehicleInfo: String = ""

    var body: some View {
        NavigationStack {
            List {
                Section("Car") {
                    StatsCell(title: "Vehicle", stat: model.nickname)
                    StatsCell(title: "Vin", stat: model.vin)
                  //  StatsCell(title: "Year", stat: model.year)
                    StatsCell(title: "Model", stat: model.model)
                    StatsCell(title: "Trim", stat: model.trim)
                    if let DENumber = model.DENumber {
                        StatsCell(title: "Dream Edition Number", stat: DENumber)
                    }
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
            .alert("Help Improve BearTalk", isPresented: $showingMailWarning) {
                Button("I Can Help") {
                    showingMailView = true
                }
                Button("Cancel", role: .cancel) {
                    showingMailWarning = false
                }
            } message: {
                Text("Sending your vehicle data will help Joe improve the app. No identifying information will be sent, and you can inspect it prior to sending.")
            }
            .task {
                await model.fetchVehicle()
                vehicleInfo = await model.getInfoString()
            }
            .sheet(isPresented: $showingMailView) {
                MailView(result: self.$result, vehicleInfo: $vehicleInfo)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingMailWarning.toggle()
                    } label: {
                        Image(systemName: "envelope.circle")
                    }
                    .disabled(!MFMailComposeViewController.canSendMail())
                }
            }
        }
    }
}

#Preview {
    StatsView(model: StatsViewModel.preview)
        .environmentObject(AppState())
}
