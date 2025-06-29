//
//  VehicleSwitcherView.swift
//  BearTalkWatch Watch App
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

struct VehicleSwitcherView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(DefaultsKey.vehicleID, store: .appGroup) private var vehicleID: String = ""
    @State private var vehicles: [VehicleIdentifierEntity] = []
    @State private var isLoading = true
    let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading vehicles...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if vehicles.isEmpty {
                VStack {
                    Image(systemName: "car.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    
                    Text("No vehicles found")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(vehicles) { vehicle in
                        VehicleRowView(
                            vehicle: vehicle,
                            isSelected: vehicle.id == vehicleID,
                            onTap: {
                                selectVehicle(vehicle)
                            }
                        )
                    }
                }
            }
        }
        .task {
            await loadVehicles()
        }
    }
    
    private func loadVehicles() async {
        do {
            let handler = VehicleIdentifierHandler(modelContainer: container)
            vehicles = try await handler.fetch()
            isLoading = false
        } catch {
            print("Failed to load vehicles: \(error)")
            isLoading = false
        }
    }
    
    private func selectVehicle(_ vehicle: VehicleIdentifierEntity) {
        vehicleID = vehicle.id
        print("Selected vehicle: \(vehicle.nickname) with ID: \(vehicle.id)")
        
        // Request updated vehicle state from phone
        WatchConnectivityManager.shared.requestVehicleStateFromPhone()
    }
}

struct VehicleRowView: View {
    let vehicle: VehicleIdentifierEntity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                if let snapshotData = vehicle.snapshotData,
                   let uiImage = UIImage(data: snapshotData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Image(systemName: "car.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 40, height: 20)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(vehicle.nickname)
                        .font(.body)
                        .foregroundStyle(isSelected ? .primary : .secondary)
                    
                    if isSelected {
                        Text("Current")
                            .font(.caption2)
                            .foregroundStyle(.accent)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
} 