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
    
    var body: some View {
        if updateAvailable {
            VStack(alignment: .leading, spacing: 12) {
                Text("Software Update Available")
                    .font(.headline)
                
                if updateInProgress {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update in progress")
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Spacer()
                            
                            Text("\(softwareUpdate?.percentComplete ?? 0)% Complete")
                                .font(.title2)
                                .bold()
                        }
                    }
                } else if updateComplete {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update complete")
                            .foregroundStyle(.secondary)
                        
                        Button("OK") {
                            showDismissAlert = true
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else if updateFailed {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Update failed")
                            .foregroundStyle(.red)
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
        }
    }
}

#Preview {
    SoftwareUpdateCell()
        .environment(DataModel())
        .padding()
        .background(.black)
} 
