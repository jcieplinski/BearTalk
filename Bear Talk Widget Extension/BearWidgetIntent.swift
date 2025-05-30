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
    
    @Parameter(title: "Control One", default: .doorLocks)
    var controlTypeOne: ControlType?
    
    @Parameter(title: "Control Two", default: .chargePort)
    var controlTypeTwo: ControlType?
    
    @Parameter(title: "Control Three", default: .frunk)
    var controlTypeThree: ControlType?
    
    @Parameter(title: "Control Four", default: .trunk)
    var controlTypeFour: ControlType?
    
    @Parameter(title: "Control Five", default: .lights)
    var controlTypeFive: ControlType?
    
    @Parameter(title: "Control Six", default: .defrost)
    var controlTypeSix: ControlType?
    
    @Parameter(title: "Control Seven", default: .climateControl)
    var controlTypeSeven: ControlType?
    
    @Parameter(title: "Control Eight", default: .maxAC)
    var controlTypeEight: ControlType?
}
