//
//  BearWidgetIntent.swift
//  Bear Talk Widget Extension
//
//  Created by Joe Cieplinski on 5/30/25.
//

import WidgetKit
import AppIntents

struct BearWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Lucid Controls" }
    static var description: IntentDescription { "Common Controls for your Lucid" }

    @Parameter(title: "Vehicle")
    var vehicle: VehicleIdentifierEntity?
    
    @Parameter(title: "Control One", default: .doorLocks, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeOne: ControlType?
    
    @Parameter(title: "Control Two", default: .hazards, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeTwo: ControlType?
    
    @Parameter(title: "Control Three", default: .frunk, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeThree: ControlType?
    
    @Parameter(title: "Control Four", default: .trunk, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeFour: ControlType?
    
    @Parameter(title: "Control Five", default: .lights, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeFive: ControlType?
    
    @Parameter(title: "Control Six", default: .defrost, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeSix: ControlType?
    
    @Parameter(title: "Control Seven", default: .climateControl, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeSeven: ControlType?
    
    @Parameter(title: "Control Eight", default: .maxAC, supportedValues: [.doorLocks, .frunk, .trunk, .climateControl, .defrost, .maxAC, .seatClimate, .steeringWheelClimate, .horn, .lights, .hazards, .windows, .rideHeight, .remoteDrive, .batteryPrecondition])
    var controlTypeEight: ControlType?
}
