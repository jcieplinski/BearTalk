//
//  VehicleIdentifierQuery.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftData
import AppIntents

struct VehicleIdentifierQuery: EntityQuery, Sendable {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            VehicleIdentifier.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    func suggestedEntities() async throws -> [VehicleIdentifierEntity] {
        return await MainActor.run {
            let descriptor = FetchDescriptor<VehicleIdentifier>()
            let fetchedVehicles = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.nickname < $1.nickname }
            
            let vehicles = fetchedVehicles ?? []
            
            return vehicles.map { vehicle -> VehicleIdentifierEntity in
                return VehicleIdentifierEntity(identifier: vehicle)
            }
        }
    }
    
    func defaultResult() async -> VehicleIdentifierEntity? {
        return await MainActor.run {
            let descriptor = FetchDescriptor<VehicleIdentifier>()
            let fetchedVehicles = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.nickname < $1.nickname }
            
            let vehicles = fetchedVehicles ?? []
            
            if let first = vehicles.first {
                return VehicleIdentifierEntity(identifier: first)
            }
            
            return nil
        }
    }
    
    func entities(for identifiers: [VehicleIdentifierEntity.ID]) async throws -> [VehicleIdentifierEntity] {
        return await MainActor.run {
            let descriptor = FetchDescriptor<VehicleIdentifier>()
            let fetchedVehicles = try? sharedModelContainer.mainContext.fetch(descriptor).sorted{ $0.nickname < $1.nickname }
            
            let vehicles = fetchedVehicles ?? []
            
            let filtered = vehicles.filter {
                identifiers.contains($0.id)
            }
            
            return filtered.map { vehicle -> VehicleIdentifierEntity in
                return VehicleIdentifierEntity(identifier: vehicle)
            }
        }
    }
}
