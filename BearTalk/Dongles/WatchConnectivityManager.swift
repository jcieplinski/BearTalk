//
//  WatchConnectivityManager.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 6/13/25.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManager: NSObject, ObservableObject {
    static let shared = WatchConnectivityManager()
    
    private let session: WCSession
    
    override init() {
        self.session = WCSession.default
        super.init()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
            print("WatchConnectivityManager: WCSession activated")
        } else {
            print("WatchConnectivityManager: WCSession not supported")
        }
    }
    
    func sendCredentialsToWatch() {
        let authorization = UserDefaults.appGroup.string(forKey: DefaultsKey.authorization) ?? ""
        let refreshToken = UserDefaults.appGroup.string(forKey: DefaultsKey.refreshToken) ?? ""
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        
        print("WatchConnectivityManager: Sending credentials to watch - vehicleID: \(vehicleID)")
        
        let context: [String: Any] = [
            "authorization": authorization,
            "refreshToken": refreshToken,
            "vehicleID": vehicleID,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        do {
            try session.updateApplicationContext(context)
            print("WatchConnectivityManager: Successfully sent credentials to watch via application context")
        } catch {
            print("WatchConnectivityManager: Failed to send credentials to watch via application context: \(error)")
        }
    }
    
    func sendCredentialsToWatchIfNeeded() {
        // Only send if watch is paired and reachable
        if session.isPaired && session.isWatchAppInstalled && session.isReachable {
            print("WatchConnectivityManager: Watch is available, sending credentials")
            sendCredentialsToWatch()
        } else {
            print("WatchConnectivityManager: Watch not available - paired: \(session.isPaired), installed: \(session.isWatchAppInstalled), reachable: \(session.isReachable)")
        }
    }
    
    func sendVehicleStateToWatch() async {
        guard session.isPaired && session.isWatchAppInstalled && session.isReachable else {
            print("WatchConnectivityManager: Watch not available for vehicle state")
            return
        }
        
        do {
            // Fetch current vehicle state
            guard let vehicle = try await BearAPI.fetchCurrentVehicle() else {
                print("WatchConnectivityManager: Failed to fetch current vehicle")
                return
            }
            
            let vehicleState = vehicle.vehicleState
            let batteryState = vehicleState.batteryState
            
            // Create a comprehensive vehicle state for the watch
            let watchVehicleState: [String: Any] = [
                "chargePercent": batteryState.chargePercent,
                "remainingRange": batteryState.remainingRange,
                "powerState": vehicleState.powerState.intValue,
                "nickname": vehicle.vehicleConfig.nickname,
                "timestamp": Date().timeIntervalSince1970,
                
                // Control state properties - send as integers
                "lockState": vehicleState.bodyState.doorLocks.intValue,
                "frunkClosureState": vehicleState.bodyState.frontCargo.intValue,
                "trunkClosureState": vehicleState.bodyState.rearCargo.intValue,
                "chargePortClosureState": vehicleState.bodyState.chargePortState.intValue,
                "lightsState": vehicleState.chassisState.headlights.intValue,
                "defrostState": vehicleState.hvacState.defrost.intvalue,
                "maxACState": vehicleState.hvacState.maxAcStatus.intValue,
                "batteryPreConditionState": vehicleState.batteryState.preconditioningStatus.intValue,
                "climatePowerState": vehicleState.hvacState.power.intValue,
                "steeringHeaterStatus": vehicleState.hvacState.steeringHeater.intValue,
                
                // Complex objects as dictionaries with actual data
                "windowPosition": [
                    "leftFront": vehicleState.bodyState.windowPosition.leftFront.intValue,
                    "leftRear": vehicleState.bodyState.windowPosition.leftRear.intValue,
                    "rightFront": vehicleState.bodyState.windowPosition.rightFront.intValue,
                    "rightRear": vehicleState.bodyState.windowPosition.rightRear.intValue
                ],
                "seatClimateState": [
                    "driverHeatBackrestZone1": vehicleState.hvacState.seats.driverHeatBackrestZone1.intValue,
                    "driverHeatBackrestZone3": vehicleState.hvacState.seats.driverHeatBackrestZone3.intValue,
                    "driverHeatCushionZone2": vehicleState.hvacState.seats.driverHeatCushionZone2.intValue,
                    "driverHeatCushionZone4": vehicleState.hvacState.seats.driverHeatCushionZone4.intValue,
                    "driverVentBackrest": vehicleState.hvacState.seats.driverVentBackrest.intValue,
                    "driverVentCushion": vehicleState.hvacState.seats.driverVentCushion.intValue,
                    "frontPassengerHeatBackrestZone1": vehicleState.hvacState.seats.frontPassengerHeatBackrestZone1.intValue,
                    "frontPassengerHeatBackrestZone3": vehicleState.hvacState.seats.frontPassengerHeatBackrestZone3.intValue,
                    "frontPassengerHeatCushionZone2": vehicleState.hvacState.seats.frontPassengerHeatCushionZone2.intValue,
                    "frontPassengerHeatCushionZone4": vehicleState.hvacState.seats.frontPassengerHeatCushionZone4.intValue,
                    "frontPassengerVentBackrest": vehicleState.hvacState.seats.frontPassengerVentBackrest.intValue,
                    "frontPassengerVentCushion": vehicleState.hvacState.seats.frontPassengerVentCushion.intValue,
                    "rearPassengerHeatLeft": vehicleState.hvacState.seats.rearPassengerHeatLeft.intValue,
                    "rearPassengerHeatCenter": vehicleState.hvacState.seats.rearPassengerHeatCenter.intValue,
                    "rearPassengerHeatRight": vehicleState.hvacState.seats.rearPassengerHeatRight.intValue
                ]
            ]
            
            print("WatchConnectivityManager: Sending comprehensive vehicle state to watch - chargePercent: \(batteryState.chargePercent)")
            
            session.sendMessage(watchVehicleState, replyHandler: { reply in
                print("WatchConnectivityManager: Successfully sent vehicle state to watch: \(reply)")
            }, errorHandler: { error in
                print("WatchConnectivityManager: Failed to send vehicle state to watch: \(error)")
            })
        } catch {
            print("WatchConnectivityManager: Error fetching vehicle state for watch: \(error)")
        }
    }
    
    // Proactive method to send vehicle state to watch when available
    func sendVehicleStateToWatchIfAvailable() async {
        // Check if watch is available
        guard session.isPaired && session.isWatchAppInstalled && session.isReachable else {
            print("WatchConnectivityManager: Watch not available for proactive vehicle state update")
            return
        }
        
        // Only send if we have valid credentials
        let vehicleID = UserDefaults.appGroup.string(forKey: DefaultsKey.vehicleID) ?? ""
        if vehicleID.isEmpty {
            print("WatchConnectivityManager: No vehicle ID available for proactive update")
            return
        }
        
        print("WatchConnectivityManager: Proactively sending vehicle state to watch")
        await sendVehicleStateToWatch()
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivityManager: WCSession activation failed: \(error)")
        } else {
            print("WatchConnectivityManager: WCSession activated successfully with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("WatchConnectivityManager: WCSession became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("WatchConnectivityManager: WCSession deactivated")
        // Reactivate for future use
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("WatchConnectivityManager: Received message from watch: \(message)")
        
        // Handle messages from watch
        if let requestType = message["requestType"] as? String {
            switch requestType {
            case "requestCredentials":
                print("WatchConnectivityManager: Watch requested credentials")
                sendCredentialsToWatch()
                replyHandler(["status": "sent"])
                
            case "requestVehicleState":
                print("WatchConnectivityManager: Watch requested vehicle state")
                Task {
                    await sendVehicleStateToWatch()
                }
                replyHandler(["status": "processing"])
                
            case "controlAction":
                if let controlTypeString = message["controlType"] as? String,
                   let controlType = ControlType(rawValue: controlTypeString) {
                    print("WatchConnectivityManager: Watch requested control action: \(controlType)")
                    
                    // Post notification to handle the control action
                    NotificationCenter.default.post(
                        name: .handleWatchControlAction,
                        object: nil,
                        userInfo: ["controlType": controlType]
                    )
                    
                    replyHandler(["status": "executed"])
                } else {
                    print("WatchConnectivityManager: Invalid control action request")
                    replyHandler(["status": "error"])
                }
                
            default:
                print("WatchConnectivityManager: Unknown request type: \(requestType)")
                replyHandler(["status": "unknown"])
            }
        } else {
            // Handle messages without request type (legacy or direct vehicle state)
            print("WatchConnectivityManager: Received message without request type, treating as vehicle state")
            replyHandler(["status": "received"])
        }
    }
} 