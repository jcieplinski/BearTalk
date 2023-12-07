//
//  MapViewModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/7/23.
//

import Foundation
import MapKit

@Observable final class MapViewModel {
    var vehicle: Vehicle?
    var gps: GPS?

    var coordinate: CLLocationCoordinate2D {
        guard let gps else { 
            return CLLocationCoordinate2D()
        }
        
        return CLLocationCoordinate2D(latitude: gps.location.latitude, longitude: gps.location.longitude)
    }

    var latitude: String {
        if let lat = gps?.location.latitude.round(to: 4) {
            return "\(lat)"
        }

        return "Unknown"
    }

    var longitude: String {
        if let lon = gps?.location.longitude.round(to: 4) {
            return "\(lon)"
        }

        return "Unknown"
    }

    var heading: Double {
        return gps?.headingPrecise ?? 0
    }

    var elevation: String {
        if let elevation = gps?.elevation {
            let elevationMeasurement = Measurement(value: Double(elevation), unit: UnitLength.centimeters)
            return elevationMeasurement.formatted(.measurement(width: .abbreviated, usage: .visibility).locale(Locale.autoupdatingCurrent))
        }

        return "Unknown"
    }

    func fetchVehicle() async {
        do {
            if let fetched = try await BearAPI.fetchCurrentVehicle() {
                vehicle = fetched
                gps = fetched.vehicleState.gps
            }
        } catch let error {
            print("Error fetching vehicle \(error)")
        }
    }

    // MARK: - Preview
    static var preview: MapViewModel {
        let model = MapViewModel()
        model.vehicle = Vehicle.example()

        return model
    }
}
