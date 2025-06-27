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
            
            // Create a simplified vehicle state for the watch
            let watchVehicleState: [String: Any] = [
                "chargePercent": batteryState.chargePercent,
                "remainingRange": batteryState.remainingRange,
                "powerState": vehicleState.powerState.intValue,
                "nickname": vehicle.vehicleConfig.nickname,
                "timestamp": Date().timeIntervalSince1970
            ]
            
            print("WatchConnectivityManager: Sending vehicle state to watch - chargePercent: \(batteryState.chargePercent)")
            
            session.sendMessage(watchVehicleState, replyHandler: { reply in
                print("WatchConnectivityManager: Successfully sent vehicle state to watch: \(reply)")
            }, errorHandler: { error in
                print("WatchConnectivityManager: Failed to send vehicle state to watch: \(error)")
            })
        } catch {
            print("WatchConnectivityManager: Error fetching vehicle state for watch: \(error)")
        }
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
                
            default:
                print("WatchConnectivityManager: Unknown request type: \(requestType)")
                replyHandler(["status": "unknown"])
            }
        } else {
            print("WatchConnectivityManager: Received message without request type")
            replyHandler(["status": "error"])
        }
    }
} 