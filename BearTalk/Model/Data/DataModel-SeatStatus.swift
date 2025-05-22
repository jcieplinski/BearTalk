//
//  DataModel-SeatStatus.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import SwiftUI

extension DataModel {
    var frontDriverSeatHeatOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.driverHeatBackrestZone1 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.driverHeatBackrestZone3 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.driverHeatCushionZone2 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.driverHeatCushionZone4 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    var frontPassengerSeatHeatOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerHeatBackrestZone1 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerHeatBackrestZone3 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerHeatCushionZone2 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerHeatCushionZone4 {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    var rearleftSeatHeatOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.rearPassengerHeatLeft {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    var rearCenterHeatOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.rearPassengerHeatCenter {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    var rearRightSeatHeatOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.rearPassengerHeatRight {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    // MARK: - Ventillation
    
    var frontDriverSeatVentOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.driverVentCushion {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.driverVentBackrest {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
    
    var frontPassengerSeatVentOn: Bool {
        guard let vehicle else { return false }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerVentCushion {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        switch vehicle.vehicleState.hvacState.seats.frontPassengerVentBackrest {
        case .unknown, .off, .UNRECOGNIZED:
            break
        case .low, .medium, .high:
            return true
        }
        
        return false
    }
}
