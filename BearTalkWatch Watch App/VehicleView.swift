//
//  VehicleView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

struct VehicleView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage(DefaultsKey.vehicleID, store: .appGroup) static var vehicleID: String = ""
    
    @Bindable var model: VehicleViewModel
    @State private var isRefreshing = false
    
    var body: some View {
        VStack {
            VStack {
                if model.nickname.isNotBlank {
                    HStack {
                        Text(model.nickname)
                            .font(.headline)
                        
                        Spacer()
                        
                        // Manual refresh button
                        Button(action: {
                            Task {
                                isRefreshing = true
                                await model.refreshVehicleState()
                                isRefreshing = false
                            }
                        }) {
                            Image(systemName: isRefreshing ? "arrow.clockwise.circle.fill" : "arrow.clockwise.circle")
                                .font(.caption)
                                .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                        .disabled(isRefreshing)
                    }
                }
                
                HStack {
                    Text("\(model.chargePercent.rounded().stringWithLocale())%")
                        .font(.title)
                    
                    Spacer()
                }
            }
            
            if let snapshotData = model.snapshotData,
               let uiImage = UIImage(data: snapshotData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 440, maxHeight: 100)
            }
        }
        .task {
            await model.setup()
        }
    }
}
