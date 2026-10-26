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
    
    @Parameter(title: "Control One", default: .doorLocks, supportedValues: ControlType.widgetControls)
    var controlTypeOne: ControlType?
    
    @Parameter(title: "Control Two", default: .chargePort, supportedValues: ControlType.widgetControls)
    var controlTypeTwo: ControlType?
    
    @Parameter(title: "Control Three", default: .frunk, supportedValues: ControlType.widgetControls)
    var controlTypeThree: ControlType?
    
    @Parameter(title: "Control Four", default: .trunk, supportedValues: ControlType.widgetControls)
    var controlTypeFour: ControlType?
    
    @Parameter(title: "Control Five", default: .lights, supportedValues: ControlType.widgetControls)
    var controlTypeFive: ControlType?
    
    @Parameter(title: "Control Six", default: .defrost, supportedValues: ControlType.widgetControls)
    var controlTypeSix: ControlType?
    
    @Parameter(title: "Control Seven", default: .climateControl, supportedValues: ControlType.widgetControls)
    var controlTypeSeven: ControlType?
    
    @Parameter(title: "Control Eight", default: .maxAC, supportedValues: ControlType.widgetControls)
    var controlTypeEight: ControlType?
}
