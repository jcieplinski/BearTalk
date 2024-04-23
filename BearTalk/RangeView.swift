//
//  RangeView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 4/23/24.
//

import SwiftUI
import AVFoundation

struct RangeView: View {
    @EnvironmentObject private var appState: AppState
    @Bindable var model: RangeViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var speechTimer: Timer?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {
                    VStack {
                        StatsCell(title: "Charge Percentage", stat: model.chargePercentage)
                        StatsCell(title: "EPA Range", stat: model.range)
                        StatsCell(title: "Current Energy", stat: "\(model.kWh.stringWithLocale()) kWh")
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
                                Image(systemName: model.showingEfficiencyPrompt ? "keyboard.fill" : "keyboard")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 48)
                                    .fontWeight(.thin)
                            }

                            Button {
                                toggleRecording()
                            } label: {
                                Image(systemName: isRecording ? "mic.fill" : "mic")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 48)
                                    .fontWeight(.light)
                            }
                            .tint(isRecording ? Color.active : .accent)
                        }
                        .padding(.bottom, 22)
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
            .scrollBounceBehavior(.basedOnSize)
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
        }
    }

    private func submit() {
        guard model.efficiencyText != "" else { return }

        model.lastEfficiency = Double(model.efficiencyText) ?? 0.0
        model.updateStats()
    }

    private func toggleRecording() {
        if !isRecording {
            speechRecognizer.resetTranscript()
            speechRecognizer.startTranscribing()
            isRecording = true

            speechTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { _ in
                toggleRecording()
            })
        } else {
            speechRecognizer.stopTranscribing()
            isRecording = false

            if let transcribed = Double(speechRecognizer.transcript) {
                model.lastEfficiency = transcribed
                model.updateStats()
            } else {

            }
        }

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

#Preview {
    RangeView(model: RangeViewModel())
        .environmentObject(AppState())
}
