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
    @State private var isFailedOrWarningDismissed = false
    @State private var isVisible = false
    @AppStorage(DefaultsKey.lastDismissedSoftwareVersion) private var lastDismissedVersion: String = ""
    
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
    
    private var currentVersion: String {
        softwareUpdate?.versionAvailable ?? ""
    }
    
    private var isUpdateCompleteDismissed: Bool {
        // Check if this specific version's update complete state has been dismissed
        return lastDismissedVersion == currentVersion && updateComplete
    }
    
    private var shouldShowCell: Bool {
        // Show cell if:
        // 1. Update is available, in progress, failed, waiting, or has warnings
        // 2. OR update is complete but hasn't been dismissed for this version
        // 3. AND failed/warning states haven't been dismissed for this session
        return !isFailedOrWarningDismissed && 
               ((updateAvailable || updateInProgress || updateWaiting) ||
                (updateFailed && !isFailedOrWarningDismissed) ||
                (updateNotStartedWithWarnings && !isFailedOrWarningDismissed) ||
                (updateComplete && !isUpdateCompleteDismissed))
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
                                // Animate out first
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isVisible = false
                                }
                                // Then update the dismiss state after animation completes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    lastDismissedVersion = currentVersion
                                }
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
                                // Animate out first
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isVisible = false
                                }
                                // Then update the dismiss state after animation completes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isFailedOrWarningDismissed = true
                                }
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
                                // Animate out first
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    isVisible = false
                                }
                                // Then update the dismiss state after animation completes
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isFailedOrWarningDismissed = true
                                }
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
            .scaleEffect(isVisible ? 1.0 : 0.8)
            .opacity(isVisible ? 1.0 : 0.0)
            .frame(maxHeight: isVisible ? .infinity : 0)
            .clipped()
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
            .onAppear {
                // Handle initial state: if AppStorage is blank, set current version to prevent showing until next update
                if lastDismissedVersion.isEmpty && !currentVersion.isEmpty {
                    lastDismissedVersion = currentVersion
                }
                
                // Animate in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isVisible = true
                }
            }
            .onChange(of: softwareUpdate?.updateAvailable) { _, newValue in
                // Reset dismissed state when a new update becomes available
                if newValue == .updateAvailable {
                    lastDismissedVersion = ""
                }
            }
            .onChange(of: softwareUpdate?.state) { _, newState in
                // Reset temporary dismiss state when update state changes
                // This allows failed/warning states to be shown again if retried
                if newState != .failed && newState != .updateFailedDriveAllowed && 
                   newState != .updateFailedNoAction && newState != .updateNotstartedWithWarnings {
                    isFailedOrWarningDismissed = false
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: shouldShowCell)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: lastDismissedVersion)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isFailedOrWarningDismissed)
        }
    }
}

#Preview {
    SoftwareUpdateCell()
        .environment(DataModel())
        .padding()
        .background(.black)
} 
