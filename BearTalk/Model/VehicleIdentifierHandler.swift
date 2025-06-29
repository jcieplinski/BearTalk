//
//  VehicleIdentifierHandler.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftUI
import SwiftData
import OSLog
import SceneKit

@ModelActor
actor VehicleIdentifierHandler {
    public func fetch() throws -> [VehicleIdentifierEntity] {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor).sorted{ $0.nickname < $1.nickname }
        
        return fetchedVehicles.map(VehicleIdentifierEntity.init)
    }
    
    public func delete(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor)
        
        let toDelete = fetchedVehicles.filter { vehicles.map(\.id).contains($0.id)}
        
        toDelete.forEach { vehicle in
            modelContext.delete(vehicle)
        }
    }
    
    public func update(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let fetchedVehicles = try modelContext.fetch(descriptor)
        
        try fetchedVehicles.forEach { vehicle in
            if let updated = vehicles.first(where: { $0.id == vehicle.id }),
               updated.nickname != vehicle.nickname {
                vehicle.nickname = updated.nickname
                try modelContext.save()
            }
        }
    }
    
    public func add(_ vehicles: [VehicleIdentifierEntity]) async throws {
        let existing = try fetch()
        
        let nonExistingVehicles = vehicles.filter { !existing.map { $0.id }.contains($0.id) }
        let expiredVehicles = existing.filter { !vehicles.map(\.self.id).contains($0.id) }
        
        try nonExistingVehicles.forEach { entity in
            let vehicle = VehicleIdentifier(id: entity.id, nickname: entity.nickname)
            modelContext.insert(vehicle)
            try modelContext.save()
        }
        
        try await delete(expiredVehicles)
        try await update(vehicles)
    }
    
    public func removeDuplicates() async throws {
        let descriptor = FetchDescriptor<VehicleIdentifier>()
        let allVehicles = try modelContext.fetch(descriptor)
        
        // Group vehicles by ID and find duplicates
        let groupedVehicles = Dictionary(grouping: allVehicles) { $0.id }
        
        var vehiclesToDelete: [VehicleIdentifier] = []
        
        for (_, vehicles) in groupedVehicles {
            if vehicles.count > 1 {
                // Keep the first vehicle, mark the rest for deletion
                let duplicates = Array(vehicles.dropFirst())
                vehiclesToDelete.append(contentsOf: duplicates)
            }
        }
        
        // Delete duplicates
        for vehicle in vehiclesToDelete {
            modelContext.delete(vehicle)
        }
        
        if !vehiclesToDelete.isEmpty {
            try modelContext.save()
            print("Removed \(vehiclesToDelete.count) duplicate vehicles")
        }
    }
}
