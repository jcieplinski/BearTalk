//
//  VehicleViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import SwiftUI
import SwiftData

@Observable class VehicleViewModel {
  //  @ObservationIgnored @AppStorage(DefaultsKey.vehicleID, store: .appGroup) var vehicleID: String = ""
    
    var nickname: String = ""
    var snapshotData: Data?
    var chargePercent: Double = 0
    var container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func setup() async {
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        do {
            let currentVehicleIdentifier = try await VehicleIdentifierHandler(modelContainer: container).fetch()
            let vehicle = currentVehicleIdentifier.first(where: { $0.id == vehicleID })
            nickname = vehicle?.nickname ?? ""
            snapshotData = vehicle?.snapshotData
            
            if let vehicle = try await BearAPI.fetchCurrentVehicle() {
                let vehicleState = vehicle.vehicleState
                
                chargePercent = vehicleState.batteryState.chargePercent
            }
        } catch {
            print("Failed to fetch current vehicle: \(error)")
        }
    }
}
