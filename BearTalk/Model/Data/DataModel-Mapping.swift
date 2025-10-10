//
//  DataModel-Mapping.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/17/25.
//

import SwiftUI
import MapKit

extension DataModel {
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
            let elevationInMeters = Double(elevation) / 100.0 // Convert cm to meters
            let currentDistanceUnit = UnitConverter.currentDistanceUnit
            let elevationConverted = UnitConverter.convertDistance(elevationInMeters, from: .kilometers, to: currentDistanceUnit)
            return UnitConverter.formatDistance(elevationConverted, unit: currentDistanceUnit)
        }
        
        return "Unknown"
    }
}
