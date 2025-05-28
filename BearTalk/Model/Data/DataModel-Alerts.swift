//
//  DataModel-Alerts.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/27/25.
//

extension DataModel {
    var alerts: [String] {
        var activeAlerts: [String] = []
        
        guard let vehicle = vehicle else { return [] }
        let bodyState = vehicle.vehicleState.bodyState
        let chassisState = vehicle.vehicleState.chassisState
        let hvacState = vehicle.vehicleState.hvacState
        let alarmState = vehicle.vehicleState.alarmState
        
        // Check doors
        if bodyState.frontLeftDoor != .closed { activeAlerts.append("Front Left Door Open") }
        if bodyState.frontRightDoor != .closed { activeAlerts.append("Front Right Door Open") }
        if bodyState.rearLeftDoor != .closed { activeAlerts.append("Rear Left Door Open") }
        if bodyState.rearRightDoor != .closed { activeAlerts.append("Rear Right Door Open") }
        
        // Check frunk and trunk
        if bodyState.frontCargo != .closed { activeAlerts.append("Frunk Open") }
        if bodyState.rearCargo != .closed { activeAlerts.append("Trunk Open") }
        
        // Check windows
        let windowPosition = bodyState.windowPosition
        if windowPosition.leftFront.isOpen { activeAlerts.append("Front Left Window Open") }
        if windowPosition.rightFront.isOpen { activeAlerts.append("Front Right Window Open") }
        if windowPosition.leftRear.isOpen { activeAlerts.append("Rear Left Window Open") }
        if windowPosition.rightRear.isOpen { activeAlerts.append("Rear Right Window Open") }
        
        // Check tire pressure warnings
        if chassisState.hardWarnLeftFront == .warningOn || chassisState.softWarnLeftFront == .warningOn { activeAlerts.append("Front Left Tire Pressure Warning") }
        if chassisState.hardWarnRightFront == .warningOn || chassisState.softWarnRightFront == .warningOn { activeAlerts.append("Front Right Tire Pressure Warning") }
        if chassisState.hardWarnLeftRear == .warningOn || chassisState.softWarnLeftRear == .warningOn { activeAlerts.append("Rear Left Tire Pressure Warning") }
        if chassisState.hardWarnRightRear == .warningOn || chassisState.softWarnRightRear == .warningOn { activeAlerts.append("Rear Right Tire Pressure Warning") }
        
        // Check climate status
        if hvacState.keepClimateStatus == .enabled { activeAlerts.append("Keep Climate On") }
        if hvacState.keepClimateStatus == .petModeOn { activeAlerts.append("Pet Mode On") }
        
        // Check panic alarm
        if alarmState.alarmStatus == .panicMode { activeAlerts.append("Panic Alarm On") }
        
        // Check keyfob battery
        if bodyState.keyfobBatteryStatus == .low { activeAlerts.append("Key Fob Battery Low") }
        
        return activeAlerts
    }
}
