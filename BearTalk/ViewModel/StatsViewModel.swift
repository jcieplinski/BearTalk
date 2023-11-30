//
//  StatsViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/30/23.
//

import SwiftUI

@Observable final class StatsViewModel {
    var vehicle: Vehicle?
    var noVehicleWarning: String = ""

    func fetchVehicle() async {
        do {
            if let fetched = try await BearAPI.fetchVehicles() {
                vehicle = fetched
            }
        } catch let error {
            print("Error fetching vehicles \(error)")
            noVehicleWarning = "No vehicles found"
        }
    }

    // MARK: - Preview
    static var preview: StatsViewModel {
        let model = StatsViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
