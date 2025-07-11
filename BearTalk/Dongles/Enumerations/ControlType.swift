//
//  ControlType.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/27/25.
//

import SwiftUI
import AppIntents
import UniformTypeIdentifiers

enum ControlType: String, Codable, Equatable, CaseIterable, Identifiable, Transferable, AppEnum {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .controlType)
    }
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Control Type")
    
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .wake: DisplayRepresentation(title: "Wake Car"),
        .doorLocks: DisplayRepresentation(title: "Door Locks"),
        .frunk: DisplayRepresentation(title: "Frunk"),
        .trunk: DisplayRepresentation(title: "Trunk"),
        .chargePort: DisplayRepresentation(title: "Charge Port"),
        .climateControl: DisplayRepresentation(title: "Climate Control"),
        .maxAC: DisplayRepresentation(title: "Max AC"),
        .seatClimate: DisplayRepresentation(title: "Seat Climate"),
        .steeringWheelClimate: DisplayRepresentation(title: "Steering Wheel Climate"),
        .defrost: DisplayRepresentation(title: "Defrost"),
        .horn: DisplayRepresentation(title: "Honk"),
        .lights: DisplayRepresentation(title: "Lights"),
        .hazards: DisplayRepresentation(title: "Hazards"),
        .windows: DisplayRepresentation(title: "Windows"),
        .batteryPrecondition: DisplayRepresentation(title: "Battery Preconditioning"),
        .softwareUpdate: DisplayRepresentation(title: "Software Update"),
        .chargeLimit: DisplayRepresentation(title: "Charge Limit"),
        .driverSeatHeat: DisplayRepresentation(title: "Driver Seat Chair"),
        .driverSeatVent: DisplayRepresentation(title: "Driver Seat Vent"),
        .passengerSeatHeat: DisplayRepresentation(title: "Passenger Seat Heat"),
        .passengerSeatVent: DisplayRepresentation(title: "Passenger Seat Vent"),
        .rearLeftSeatHeat: DisplayRepresentation(title: "Rear Left Seat Heat"),
        .rearCenterSeatHeat: DisplayRepresentation(title: "Rear Center Seat Heat"),
        .rearRightSeatHeat: DisplayRepresentation(title: "Rear Right Seat Heat"),
        .alarm: DisplayRepresentation(title: "Alarm"),
    ]
    
    case wake
    case doorLocks
    case frunk
    case trunk
    case chargePort
    case climateControl
    case maxAC
    case seatClimate
    case steeringWheelClimate
    case defrost
    case horn
    case lights
    case hazards
    case windows
    case batteryPrecondition
    case softwareUpdate
    
    case chargeLimit
    case driverSeatHeat
    case driverSeatVent
    case passengerSeatHeat
    case passengerSeatVent
    case rearLeftSeatHeat
    case rearCenterSeatHeat
    case rearRightSeatHeat
    case alarm
    
    var id: Self { self }
    
    static var allCases: [ControlType] {
        // We remove some items from allCases here. We don't want buttons for every type
        return [.doorLocks, .frunk, .trunk, .chargePort, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .windows, .batteryPrecondition]
    }
    
    static var allCasesGravity: [ControlType] {
        // We remove some items from allCases here. We don't want buttons for every type
        return [.doorLocks, .frunk, .trunk, .chargePort, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .batteryPrecondition]
    }
    
    var title: LocalizedStringKey {
        switch self {
        case .wake:
            "Wake Up"
        case .doorLocks:
            "Door Locks"
        case .frunk:
            "Frunk"
        case .trunk:
            "Trunk"
        case .chargePort:
            "Charge Port"
        case .defrost:
            "Defrost"
        case .maxAC:
            "Max AC"
        case .seatClimate:
            "Seat Climate"
        case .steeringWheelClimate:
            "Steering Wheel Heat"
        case .horn:
            "Honk Horn"
        case .lights:
            "Lights"
        case .hazards:
            "Hazard Lights"
        case .windows:
            "Windows"
        case .batteryPrecondition:
            "Precondition Battery"
        case .chargeLimit:
            "Charge Limit"
        case .climateControl:
            "Climate Control"
        case .driverSeatHeat:
            "Driver Seat Heat"
        case .driverSeatVent:
            "Driver Seat Vent"
        case .passengerSeatHeat:
            "Passenger Seat Heat"
        case .passengerSeatVent:
            "Passenger Seat Vent"
        case .rearLeftSeatHeat:
            "Rear Left Seat Heat"
        case .rearCenterSeatHeat:
            "Rear Center Seat Heat"
        case .rearRightSeatHeat:
            "Rear Right Seat Heat"
        case .alarm:
            "Shock and Tilt Alarm"
        case .softwareUpdate:
            ""
        }
    }
    
    var offImage: String {
        switch self {
        case .wake:
            ""
        case .doorLocks:
            "doorsUnlocked"
        case .frunk:
            "frunkClosed"
        case .trunk:
            "trunkClosed"
        case .chargePort:
            "chargePortClosed"
        case .defrost:
            "defrostOff"
        case .maxAC:
            "maxAcOff"
        case .seatClimate, .driverSeatHeat, .passengerSeatHeat, .rearLeftSeatHeat, .rearCenterSeatHeat, .rearRightSeatHeat:
            "seatClimateOff"
        case .driverSeatVent, .passengerSeatVent:
            "seatVentOff"
        case .steeringWheelClimate:
            "steeringWheelOff"
        case .horn:
            "hornOff"
        case .lights:
            "lightsOff"
        case .hazards:
            "hazardsOff"
        case .windows:
            "windowClosed"
        case .batteryPrecondition:
            "batteryOff"
        case .chargeLimit:
            ""
        case .climateControl:
            "climateOff"
        case .alarm:
            ""
        case .softwareUpdate:
            ""
        }
    }
    
    var onImage: String {
        switch self {
        case .wake:
            ""
        case .doorLocks:
            "doorsLocked"
        case .frunk:
            "frunkOpen"
        case .trunk:
            "trunkOpen"
        case .chargePort:
            "chargePortOpen"
        case .defrost:
            "defrostOn"
        case .maxAC:
            "maxAcOn"
        case .seatClimate, .driverSeatHeat, .passengerSeatHeat, .rearLeftSeatHeat, .rearCenterSeatHeat, .rearRightSeatHeat:
            "seatClimateOn"
        case .driverSeatVent, .passengerSeatVent:
            "seatVentOn"
        case .steeringWheelClimate:
            "steeringWheelOn"
        case .horn:
            "hornOn"
        case .lights:
            "lightsOn"
        case .hazards:
            "hazardsOn"
        case .windows:
            "windowOpen"
        case .batteryPrecondition:
            "batteryOn"
        case .chargeLimit:
            ""
        case .climateControl:
            "climateOn"
        case .alarm:
            ""
        case .softwareUpdate:
            ""
        }
    }
}
