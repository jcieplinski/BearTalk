//
//  SeatClimateIntent.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/22/25.
//

import AppIntents

struct SeatClimateIntent: AppIntent {
    enum IntensityLevel: Int, AppEnum {
        case off
        case low
        case medium
        case high
        
        static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Intensity Level")
        
        static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
            .off: DisplayRepresentation(title: "Off"),
            .low: DisplayRepresentation(title: "Low"),
            .medium: DisplayRepresentation(title: "Medium"),
            .high: DisplayRepresentation(title: "High")
        ]
    }
    
    static var title: LocalizedStringResource = "Seat Climate"
    
    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Intensity Level")
    var level: IntensityLevel
    
    @Parameter(title: "Driver Seat Heat")
    var driverSeatHeat: Bool
    
    @Parameter(title: "Driver Seat Ventilation")
    var driverSeatVentilation: Bool
    
    @Parameter(title: "Passenger Seat Heat")
    var passengerSeatHeat: Bool
    
    @Parameter(title: "Passenger Seat Ventilation")
    var passengerSeatVentilation: Bool
    
    @Parameter(title: "Rear Left Seat Heat")
    var rearLeftSeatHeat: Bool
    
    @Parameter(title: "Rear Center Seat Heat")
    var rearCenterSeatHeat: Bool
    
    @Parameter(title: "Rear Right Seat Heat")
    var rearRightSeatHeat: Bool
    
    @MainActor func perform() async throws -> some IntentResult {
        let _ = try await BearAPI.refreshToken()
        let vehicle = try await BearAPI.fetchVehicles()?.first(where: { $0.vehicleId == self.vehicle?.id })
        
        var seatAssignments: [SeatAssignment] = []
        
        if driverSeatHeat {
            seatAssignments.append(.driverHeatBackrestZone1(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.driverHeatBackrestZone3(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.driverHeatCushionZone2(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.driverHeatCushionZone4(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if driverSeatVentilation {
            seatAssignments.append(.driverVentBackrest(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.driverVentCushion(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if passengerSeatHeat {
            seatAssignments.append(.frontPassengerHeatBackrestZone1(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.frontPassengerHeatBackrestZone3(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.frontPassengerHeatCushionZone2(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.frontPassengerHeatCushionZone4(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if passengerSeatVentilation {
            seatAssignments.append(.frontPassengerVentBackrest(mode: SeatClimateMode(levelInt: level.rawValue)))
            seatAssignments.append(.frontPassengerVentCushion(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if rearLeftSeatHeat {
            seatAssignments.append(.rearPassengerHeatLeft(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if rearCenterSeatHeat {
            seatAssignments.append(.rearPassengerHeatCenter(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if rearRightSeatHeat {
            seatAssignments.append(.rearPassengerHeatRight(mode: SeatClimateMode(levelInt: level.rawValue)))
        }
        
        if let vehicleID = vehicle?.vehicleId {
            let _ = try await BearAPI.setSeatClimate(vehicleID: vehicleID, seats: seatAssignments)
        } else {
            let _ = try await BearAPI.setSeatClimate(seats: seatAssignments)
        }
        
        return .result()
    }
}
