//
//  RangeView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 4/23/24.
//

import SwiftUI
import AVFoundation

struct RangeView: View {
    @Environment(AppState.self) var appState: AppState
    @Environment(DataModel.self) var model: DataModel
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    @State private var speechTimer: Timer?

    var body: some View {
        @Bindable var model = model
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
                                .font(.system(size: 88))
                                .fontWeight(.bold)
//                            Text(model.unitLabel)
//                                .font(.title)
                        }
                        Text("estimated real-world range")
                    }

                    Spacer()

                    VStack(spacing: 22) {
                        Text("Based on most recently\nupdated efficiency of")
                            .multilineTextAlignment(.center)
                        Text(model.lastEfficiency.round(to: 2).stringWithLocale())
                            .font(.largeTitle)
                        
                        if model.isCalculatingEfficiency {
                            HStack {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Calculating efficiency...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Text("Vehicle not in motion")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

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
                        
                        Text("Efficiency and estimated range will update automatically if you leave this app open while driving. Please keep your eyes on the road at all times and obey local traffic laws.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .tint(.accent)
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        model.updateRangeStats()
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
                model.updateRangeStats()
            } else {

            }
        }

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}

#Preview {
    RangeView()
        .environment(AppState())
        .environment(DataModel())
}
