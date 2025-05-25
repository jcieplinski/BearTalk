//
//  ContentView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import GRPCCore

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(DataModel.self) var model
    @EnvironmentObject private var appState: AppState
    @AppStorage(DefaultsKey.refreshToken, store: .appGroup) var refreshToken: String = ""
    @AppStorage(DefaultsKey.tokenExpiryTime, store: .appGroup) private var tokenExpiryTime: Double = 0
    
    @State var refreshTimer: Timer?
    @State var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    private let REFRESH_BUFFER_SECONDS = 900 // 15 minutes before expiry
    private let MIN_REFRESH_INTERVAL = 60 // Minimum 1 minute between refresh attempts
    private let MAX_REFRESH_INTERVAL = 1800 // Maximum 30 minutes between refresh attempts
    private let MAX_TOKEN_LIFETIME = 86400 // Maximum token lifetime of 24 hours
    private let MIN_TOKEN_LIFETIME = 60 // Minimum token lifetime of 1 minute
    
    private func validateExpiryTime(_ expiryTimeInSeconds: Int) -> Bool {
        // Token should not be valid for more than 24 hours
        guard expiryTimeInSeconds <= MAX_TOKEN_LIFETIME else {
            print("Invalid expiry time: \(expiryTimeInSeconds)s exceeds maximum allowed lifetime of \(MAX_TOKEN_LIFETIME)s")
            return false
        }
        
        // Token should not be valid for less than 1 minute
        guard expiryTimeInSeconds >= MIN_TOKEN_LIFETIME else {
            print("Invalid expiry time: \(expiryTimeInSeconds)s is less than minimum allowed lifetime of \(MIN_TOKEN_LIFETIME)s")
            return false
        }
        
        return true
    }
    
    private func calculateRefreshTime(_ timeUntilExpiry: Int) -> Int {
        // If token expires in less than 2 minutes, refresh immediately
        if timeUntilExpiry <= 120 {
            return 0
        }
        
        // If token expires in less than 5 minutes, refresh in 1 minute
        if timeUntilExpiry <= 300 {
            return 60
        }
        
        // Otherwise, refresh at 1/3 of the remaining time, but not more than MAX_REFRESH_INTERVAL
        return min(timeUntilExpiry / 3, MAX_REFRESH_INTERVAL)
    }
    
    private func logTokenStatus() {
        let currentTime = Date().timeIntervalSince1970
        let timeUntilExpiry = tokenExpiryTime - currentTime
        let expiryDate = Date(timeIntervalSince1970: tokenExpiryTime)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        
        print("""
        Token Status:
        - Current Time: \(formatter.string(from: Date()))
        - Expiry Time: \(formatter.string(from: expiryDate))
        - Time Until Expiry: \(Int(timeUntilExpiry))s
        - Refresh Buffer: \(REFRESH_BUFFER_SECONDS)s
        - Token Valid: \(timeUntilExpiry > 0)
        - Refresh Token Present: \(refreshToken.isNotBlank)
        - Expiry Time Valid: \(validateExpiryTime(Int(timeUntilExpiry)))
        """)
    }
    
    private func handleInvalidToken() {
        print("Handling invalid token state")
        tokenExpiryTime = 0
        appState.loggedIn = false
        appState.appHoldScreen = false
    }
    
    private func checkTokenValidity() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let timeUntilExpiry = tokenExpiryTime - currentTime
        
        // Check if we have a refresh token
        guard refreshToken.isNotBlank else {
            print("No refresh token available")
            handleInvalidToken()
            return false
        }
        
        // Validate the expiry time
        guard validateExpiryTime(Int(timeUntilExpiry)) else {
            print("Token has invalid expiry time, forcing refresh")
            handleInvalidToken()
            return false
        }
        
        // Check if token is expired
        guard timeUntilExpiry > 0 else {
            print("Token is expired")
            handleInvalidToken()
            return false
        }
        
        return true
    }
    
    private func setRefreshTimer(seconds: Int) {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(seconds),
            repeats: false
        ) { _ in
            Task { @Sendable in
                await refreshAuth()
            }
        }
    }
    
    @Sendable
    private func refreshAuth() async {
        print("Starting token refresh")
        await refreshAuthWithRetry(maxRetries: 3, initialDelay: 1.0)
        logTokenStatus()
        
        // After token refresh, proceed with vehicle fetch
        print("Proceeding with vehicle fetch after token refresh")
        do {
            print("Starting profile and vehicle fetch")
            try await model.getUserProfile()
            
            // Check if we got a vehicle
            if let vehicle = model.vehicle {
                print("Vehicle fetched successfully: \(vehicle.vehicleId)")
                // Only start refreshing if we successfully got the vehicle
                model.startRefreshing()
            } else {
                print("No vehicle available after profile fetch")
                // Try one more time after a short delay
                print("Waiting 2 seconds before retry")
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                print("Retrying profile and vehicle fetch")
                try? await model.getUserProfile()
                
                if let vehicle = model.vehicle {
                    print("Vehicle fetched successfully on retry: \(vehicle.vehicleId)")
                    model.startRefreshing()
                } else {
                    print("Still no vehicle after retry")
                    // Check if we have a vehicle ID but failed to fetch
                    if BearAPI.vehicleID.isNotBlank {
                        print("Have vehicleID but failed to fetch vehicle state")
                        // Try one final time with a wake request
                        print("Attempting to wake vehicle")
                        if let wakeSuccess = try? await BearAPI.wakeUp(), wakeSuccess {
                            print("Wake request sent successfully, waiting 5 seconds")
                            try? await Task.sleep(nanoseconds: 5_000_000_000)
                            print("Final attempt to fetch vehicle")
                            try? await model.getUserProfile()
                            if model.vehicle != nil {
                                print("Vehicle fetched after wake request")
                                model.startRefreshing()
                            }
                        } else {
                            print("Wake request failed or returned false")
                        }
                    }
                }
            }
        } catch {
            print("Error fetching profile and vehicles: \(error)")
            // If we get an auth error, try refreshing and fetching again
            if let rpcError = error as? GRPCCore.RPCError, rpcError.code == .unauthenticated {
                print("Auth error during profile fetch, attempting refresh")
                await refreshAuth() // This will recursively try again
            }
        }
    }
    
    @Sendable
    private func refreshAuthWithRetry(maxRetries: Int, initialDelay: Double) async {
        var currentRetry = 0
        var delay = initialDelay
        
        while currentRetry <= maxRetries {
            do {
                print("Attempting token refresh (attempt \(currentRetry + 1)/\(maxRetries + 1))")
                let refreshTimeInSec = try await BearAPI.refreshToken()
                
                if refreshTimeInSec > 0 && validateExpiryTime(refreshTimeInSec) {
                    print("Token refresh successful, new expiry in \(refreshTimeInSec)s")
                    appState.loggedIn = true
                    // Store the expiry time
                    tokenExpiryTime = Date().timeIntervalSince1970 + Double(refreshTimeInSec)
                    
                    // Calculate when to refresh next
                    let refreshInSeconds = calculateRefreshTime(refreshTimeInSec)
                    if refreshInSeconds > 0 {
                        print("Setting refresh timer for \(refreshInSeconds)s from now")
                        setRefreshTimer(seconds: refreshInSeconds)
                    } else {
                        print("Token expires very soon, will refresh again immediately")
                        // Schedule immediate refresh
                        Task { @Sendable in
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                            await refreshAuth()
                        }
                    }
                    return
                } else {
                    print("Token refresh returned invalid expiry time: \(refreshTimeInSec)s")
                    throw NSError(domain: "BearTalk", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid refresh time"])
                }
            } catch let error {
                print("Token refresh attempt \(currentRetry + 1) failed: \(error)")
                
                // If we've exhausted all retries or got an unauthenticated error, handle accordingly
                if currentRetry == maxRetries || (error as? RPCError)?.code == .unauthenticated {
                    print("Token refresh failed after \(currentRetry + 1) attempts")
                    if let rpcError = error as? RPCError,
                       rpcError.code == .unauthenticated {
                        print("Unauthenticated error, clearing tokens")
                        tokenExpiryTime = 0
                        appState.loggedIn = false
                        appState.appHoldScreen = false
                    }
                    return
                }
                
                // Wait before retrying with exponential backoff
                print("Waiting \(delay)s before retry")
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                currentRetry += 1
                delay *= 2 // Exponential backoff
            }
        }
    }
    
    private func startBackgroundTask() {
        print("Starting background task")
        // End any existing background task
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
        }
        
        // Start new background task
        backgroundTask = UIApplication.shared.beginBackgroundTask { [self] in
            print("Background task expiring")
            // Cleanup when background task expires
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
        
        // Schedule background refresh
        Task { @Sendable in
            logTokenStatus()
            
            if !checkTokenValidity() {
                print("Token validation failed in background, attempting refresh")
                await refreshAuthWithRetry(maxRetries: 1, initialDelay: 0.5)
                return
            }
            
            let currentTime = Date().timeIntervalSince1970
            let timeUntilExpiry = tokenExpiryTime - currentTime
            
            // Check if we need to refresh before the background task expires
            if timeUntilExpiry <= Double(REFRESH_BUFFER_SECONDS) {
                print("Background: Token expires soon (\(Int(timeUntilExpiry))s), refreshing now")
                // Use a shorter retry count and delay for background refresh
                await refreshAuthWithRetry(maxRetries: 1, initialDelay: 0.5)
            } else {
                print("Background: Token still valid for \(Int(timeUntilExpiry))s, no refresh needed")
            }
            
            // End background task
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
    }
    
    var body: some View {
        Group {
            if appState.noCarMode {
                NoCarView()
            } else if appState.appHoldScreen {
                Spacer()
            } else if appState.loggedIn {
                TabView(selection: $appState.selectedTab) {
                    ControlsView()
                        .tabItem {
                            Image("home")
                            Text("Home")
                        }
                        .tag(AppTab.home)
                    MapView()
                        .tabItem {
                            Image("location")
                            Text("Location")
                        }
                        .tag(AppTab.map)
                    RangeView()
                        .tabItem {
                            Image("range")
                            Text("Range")
                        }
                        .tag(AppTab.range)
                    StatsView()
                        .tabItem {
                            Image("stats")
                            Text("Stats")
                        }
                        .tag(AppTab.stats)
                }
                .tint(Color(uiColor: .label))
            } else {
                LoginView()
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
        )
        .onAppear {
            Task { @Sendable in
                print("ContentView appeared")
                logTokenStatus()
                
                if !checkTokenValidity() {
                    print("Token validation failed, attempting refresh")
                    await refreshAuth()
                    return
                }
                
                let currentTime = Date().timeIntervalSince1970
                let timeUntilExpiry = tokenExpiryTime - currentTime
                
                // If token is expired or about to expire, refresh it
                if timeUntilExpiry <= Double(REFRESH_BUFFER_SECONDS) {
                    print("Token expires soon (\(Int(timeUntilExpiry))s), refreshing now")
                    await refreshAuth()
                } else {
                    print("Token is valid, proceeding with startup")
                    // If we have a valid token, we should be logged in
                    appState.loggedIn = true
                    
                    // Set refresh timer to refresh before expiry
                    let refreshInSeconds = calculateRefreshTime(Int(timeUntilExpiry))
                    if refreshInSeconds > 0 {
                        print("Setting refresh timer for \(refreshInSeconds)s from now")
                        setRefreshTimer(seconds: refreshInSeconds)
                    } else {
                        print("Token expires very soon, will refresh again immediately")
                        // Schedule immediate refresh
                        Task { @Sendable in
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                            await refreshAuth()
                        }
                    }
                    
                    // Start vehicle fetch
                    await refreshAuth()
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            switch newPhase {
            case .inactive, .background:
                print("App entering background/inactive state")
                refreshTimer?.invalidate()
                refreshTimer = nil
                
                // Start background task for token refresh
                startBackgroundTask()
                
                model.stopRefreshing()
            case .active:
                print("App becoming active")
                logTokenStatus()
                
                // End any background task
                if backgroundTask != .invalid {
                    UIApplication.shared.endBackgroundTask(backgroundTask)
                    backgroundTask = .invalid
                }
                
                Task { @Sendable in
                    if !checkTokenValidity() {
                        print("Token validation failed on app activation, attempting refresh")
                        await refreshAuth()
                        return
                    }
                    
                    let currentTime = Date().timeIntervalSince1970
                    let timeUntilExpiry = tokenExpiryTime - currentTime
                    
                    // If token is expired or about to expire, refresh it
                    if timeUntilExpiry <= Double(REFRESH_BUFFER_SECONDS) {
                        print("Token expires soon (\(Int(timeUntilExpiry))s), refreshing now")
                        await refreshAuth()
                    } else {
                        // If we have a valid token, we should be logged in
                        appState.loggedIn = true
                        model.startRefreshing()
                        
                        // Set refresh timer to refresh before expiry
                        let refreshInSeconds = calculateRefreshTime(Int(timeUntilExpiry))
                        if refreshInSeconds > 0 {
                            print("Setting refresh timer for \(refreshInSeconds)s from now")
                            setRefreshTimer(seconds: refreshInSeconds)
                        } else {
                            print("Token expires very soon, will refresh again immediately")
                            // Schedule immediate refresh
                            Task { @Sendable in
                                try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                                await refreshAuth()
                            }
                        }
                    }
                    
                    appState.appHoldScreen = false
                }
            @unknown default:
                refreshTimer?.invalidate()
                refreshTimer = nil
                model.stopRefreshing()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.preview)
        .environment(DataModel())
}
