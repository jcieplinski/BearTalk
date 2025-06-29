//
//  WatchConnectivityManager.swift
//  BearTalkWatch Watch App
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
    
    func requestCredentialsFromPhone() {
        guard session.isReachable else {
            print("WatchConnectivityManager: Phone is not reachable")
            return
        }
        
        print("WatchConnectivityManager: Requesting credentials from phone")
        
        let message: [String: Any] = [
            "requestType": "requestCredentials"
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("WatchConnectivityManager: Successfully requested credentials from phone: \(reply)")
        }, errorHandler: { error in
            print("WatchConnectivityManager: Failed to request credentials from phone: \(error)")
        })
    }
    
    func requestVehicleStateFromPhone() {
        guard session.isReachable else {
            print("WatchConnectivityManager: Phone is not reachable")
            return
        }
        
        print("WatchConnectivityManager: Requesting vehicle state from phone")
        
        let message: [String: Any] = [
            "requestType": "requestVehicleState"
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("WatchConnectivityManager: Successfully requested vehicle state from phone: \(reply)")
        }, errorHandler: { error in
            print("WatchConnectivityManager: Failed to request vehicle state from phone: \(error)")
        })
    }
    
    func sendControlAction(_ controlType: ControlType) {
        guard session.isReachable else {
            print("WatchConnectivityManager: Phone is not reachable")
            return
        }
        
        print("WatchConnectivityManager: Sending control action to phone: \(controlType.rawValue)")
        
        let message: [String: Any] = [
            "requestType": "controlAction",
            "controlType": controlType.rawValue
        ]
        
        session.sendMessage(message, replyHandler: { reply in
            print("WatchConnectivityManager: Successfully sent control action to phone: \(reply)")
        }, errorHandler: { error in
            print("WatchConnectivityManager: Failed to send control action to phone: \(error)")
        })
    }
    
    func checkExistingApplicationContext() {
        let context = session.receivedApplicationContext
        if !context.isEmpty {
            print("WatchConnectivityManager: Found existing application context: \(context)")
            handleCredentials(context)
        } else {
            print("WatchConnectivityManager: No existing application context found")
        }
    }
    
    // Debug method to log current session state
    func logSessionState() {
        print("WatchConnectivityManager: Session state - reachable: \(session.isReachable), activationState: \(session.activationState.rawValue)")
    }
    
    // Callback to notify when credentials are received
    var onCredentialsReceived: (() -> Void)?
    
    // Callback to notify when vehicle state is received
    var onVehicleStateReceived: (([String: Any]) -> Void)?
}

extension WatchConnectivityManager: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WatchConnectivityManager: WCSession activation failed: \(error)")
        } else {
            print("WatchConnectivityManager: WCSession activated successfully with state: \(activationState.rawValue)")
            
            // Check for existing application context after activation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.checkExistingApplicationContext()
            }
        }
    }
    
    // Handle application context updates from phone
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("WatchConnectivityManager: Received application context from phone: \(applicationContext)")
        handleCredentials(applicationContext)
    }
    
    // Handle messages without reply handler (for backward compatibility)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WatchConnectivityManager: Received message from phone: \(message)")
        
        // Check if this is a vehicle state message
        if message["chargePercent"] != nil {
            handleVehicleState(message)
        } else {
            handleCredentials(message)
        }
    }
    
    // Handle messages with reply handler (for requests to phone)
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("WatchConnectivityManager: Received message with reply handler from phone: \(message)")
        
        // Check if this is a vehicle state message
        if message["chargePercent"] != nil {
            handleVehicleState(message)
        } else {
            handleCredentials(message)
        }
        
        replyHandler(["status": "received"])
    }
    
    private func handleCredentials(_ data: [String : Any]) {
        // Handle incoming credentials from phone
        if let authorization = data["authorization"] as? String,
           let refreshToken = data["refreshToken"] as? String,
           let vehicleID = data["vehicleID"] as? String {
            
            // Store the received credentials in UserDefaults
            UserDefaults.appGroup.set(authorization, forKey: DefaultsKey.authorization)
            UserDefaults.appGroup.set(refreshToken, forKey: DefaultsKey.refreshToken)
            UserDefaults.appGroup.set(vehicleID, forKey: DefaultsKey.vehicleID)
            
            print("WatchConnectivityManager: Received and stored credentials from phone - authorization: \(authorization.prefix(10))..., refreshToken: \(refreshToken.prefix(10))..., vehicleID: \(vehicleID)")
            
            // Notify that credentials were received
            DispatchQueue.main.async {
                self.onCredentialsReceived?()
            }
        } else {
            print("WatchConnectivityManager: Data received but missing required credentials")
        }
    }
    
    private func handleVehicleState(_ data: [String : Any]) {
        // Handle incoming vehicle state from phone
        print("WatchConnectivityManager: Received vehicle state from phone: \(data)")
        
        // Notify that vehicle state was received
        DispatchQueue.main.async {
            self.onVehicleStateReceived?(data)
        }
    }
} 