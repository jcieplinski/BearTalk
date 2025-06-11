//
//  SoftwareUpdateCell.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftUI

struct SoftwareUpdateCell: View {
    @Environment(DataModel.self) var model
    @State private var showUpdateAlert = false
    @State private var showDismissAlert = false
    @State private var isDismissed = false
    
    private var softwareUpdate: SoftwareUpdate? {
        model.vehicle?.vehicleState.softwareUpdate
    }
    
    private var state: UpdateState {
        softwareUpdate?.state ?? .unknown
    }
    
    private var updateAvailable: Bool {
        softwareUpdate?.updateAvailable == .updateAvailable
    }
    
    private var updateInProgress: Bool {
        softwareUpdate?.state == .inProgress
    }
    
    private var updateComplete: Bool {
        softwareUpdate?.state == .success || softwareUpdate?.state == .updateSuccessWithWarnings
    }
    
    private var updateFailed: Bool {
        softwareUpdate?.state == .failed || softwareUpdate?.state == .updateFailedDriveAllowed || softwareUpdate?.state == .updateFailedNoAction
    }
    
    private var updateWaiting: Bool {
        softwareUpdate?.state == .waitingOnBcm
    }
    
    private var updateNotStartedWithWarnings: Bool {
        softwareUpdate?.state == .updateNotstartedWithWarnings
    }
    
    private var shouldShowCell: Bool {
        !isDismissed && (updateAvailable || updateInProgress || updateComplete || updateFailed || updateWaiting || updateNotStartedWithWarnings)
    }
    
    private var titleForCurrentState: String {
        switch state {
        case .unknown:
            return "Software Update Available"
        case .inProgress:
            return "Update in progress"
        case .success, .updateSuccessWithWarnings:
            return "Update complete"
        case .failed, .updateFailedDriveAllowed, .updateFailedNoAction:
            return "Update failed"
        case .waitingOnBcm:
            return "Waiting on BCM"
        case .updateNotstartedWithWarnings:
            return "Update not started with warnings"
        case .UNRECOGNIZED(_):
            return ""
        }
    }
    
    var body: some View {
        if shouldShowCell {
            VStack(alignment: .leading, spacing: 12) {
                Text(titleForCurrentState)
                    .font(.headline)
                
                if updateInProgress {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Installing software update...")
                            .foregroundStyle(.secondary)
                        
                        if let version = softwareUpdate?.versionAvailable, !version.isEmpty {
                            Text("Updating to version \(version)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        // Progress bar
                        ProgressView(value: Double(softwareUpdate?.percentComplete ?? 0), total: 100.0)
                            .progressViewStyle(LinearProgressViewStyle(tint: .accent))
                            .animation(.easeInOut(duration: 0.5), value: softwareUpdate?.percentComplete ?? 0)
                        
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(softwareUpdate?.percentComplete ?? 0)% Complete")
                                    .font(.title2)
                                    .bold()
                                    .foregroundStyle(.accent)
                                
                                if let installDuration = softwareUpdate?.installDurationMinutes, installDuration > 0 {
                                    Text("Est. \(installDuration) min remaining")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                } else if updateComplete {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update completed successfully")
                            .foregroundStyle(.green)
                        
                        HStack {
                            Spacer()
                            
                            Button("Dismiss") {
                                // For now, we'll just hide the cell by not showing it
                                // In a real implementation, you might want to call an API to clear the state
                                isDismissed = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else if updateFailed {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update failed")
                            .foregroundStyle(.red)
                        
                        HStack {
                            Spacer()
                            
                            Button("Dismiss") {
                                // For now, we'll just hide the cell by not showing it
                                // In a real implementation, you might want to call an API to clear the state
                                isDismissed = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else if updateWaiting {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Waiting for vehicle systems to be ready")
                            .foregroundStyle(.secondary)
                        
                        // Show a spinner for waiting state
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                } else if updateNotStartedWithWarnings {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update not started - warnings detected")
                            .foregroundStyle(.orange)
                        
                        HStack {
                            Spacer()
                            
                            Button("Dismiss") {
                                // For now, we'll just hide the cell by not showing it
                                // In a real implementation, you might want to call an API to clear the state
                                isDismissed = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Version: \(softwareUpdate?.versionAvailable ?? "")")
                            .foregroundStyle(.secondary)
                        
                        Text("Installation Duration: \(softwareUpdate?.installDurationMinutes ?? 0) minutes")
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Spacer()
                            
                            Button("Begin Update") {
                                showUpdateAlert = true
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                ZStack {
                    Color.active.opacity(0.1)
                    Rectangle()
                        .foregroundStyle(.ultraThinMaterial)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .alert("Software Update", isPresented: $showUpdateAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Begin Update") {
                    Task {
                        await model.startSoftwareUpdate()
                    }
                }
            } message: {
                Text("Be sure the car is in park and in a safe place. Your car will be unavailable while this update installs.")
            }
            .onChange(of: softwareUpdate?.updateAvailable) { _, newValue in
                // Reset dismissed state when a new update becomes available
                if newValue == .updateAvailable {
                    isDismissed = false
                }
            }
        }
    }
}

#Preview {
    SoftwareUpdateCell()
        .environment(DataModel())
        .padding()
        .background(.black)
} 
