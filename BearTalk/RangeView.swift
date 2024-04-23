//
//  RangeView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 4/23/24.
//

import SwiftUI

struct RangeView: View {
    @EnvironmentObject private var appState: AppState
    @Bindable var model: RangeViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                VStack {
                    StatsCell(title: "Charge Percentage", stat: model.chargePercentage)
                    StatsCell(title: "EPA range", stat: model.range)
                    StatsCell(title: "Current kWh", stat: "\(model.kWh.stringWithLocale())")
                }

                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        Text(model.estimatedRange)
                            .font(.system(size: 100))
                            .fontDesign(.rounded)
                            .fontWeight(.bold)
                        Text(model.unitLabel)
                            .font(.title)
                            .fontDesign(.rounded)
                    }
                    Text("estimated real-world range")
                }

                Spacer()

                VStack(spacing: 22) {
                    Text("Based on most recently\nupdated efficiency of")
                        .multilineTextAlignment(.center)
                    Text(model.lastEfficiency.round(to: 2).stringWithLocale())
                        .font(.largeTitle)
                        .fontDesign(.rounded)

                    HStack(spacing: 66) {
                        Button {
                            model.efficiencyText = ""
                            model.showingEfficiencyPrompt = true
                        } label: {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 66))
                                .fontWeight(.light)
                        }

                        Button {

                        } label: {
                            Image(systemName: "mic.circle")
                                .font(.system(size: 66))
                                .fontWeight(.light)
                        }
                    }
                }
            }
            .tint(.accent)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                await model.fetchVehicle()
            }
            .navigationTitle("Range")
            .navigationBarTitleDisplayMode(.inline)
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
            .alert("What is your current efficiency?", isPresented: $model.showingEfficiencyPrompt) {
                TextField("Enter decimal number only", text: $model.efficiencyText)
                    .keyboardType(.decimalPad)
                    .onSubmit {
                        submit()
                    }
                Button(role: .cancel) {
                    model.showingEfficiencyPrompt = false
                } label: {
                    Text("Cancel")
                }
                Button {
                    model.showingEfficiencyPrompt = false
                    submit()
                } label: {
                    Text("Set Efficiency")
                }
                .keyboardShortcut(.defaultAction)
            } message: {
                Text("")
            }
        }
    }

    private func submit() {
        guard model.efficiencyText != "" else { return }

        model.lastEfficiency = Double(model.efficiencyText) ?? 0.0
        model.updateStats()
    }
}

#Preview {
    RangeView(model: RangeViewModel())
        .environmentObject(AppState())
}
