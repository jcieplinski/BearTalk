import SwiftUI
import GRPCCore
import Combine
import Observation

@Observable
final class TokenManager {
    // MARK: - Published Properties
    var isLoggedIn = false
    var isAppHoldScreen = false
    
    // MARK: - AppStorage Properties
    @ObservationIgnored @AppStorage(DefaultsKey.refreshToken, store: .appGroup) var refreshToken: String = ""
    @ObservationIgnored @AppStorage(DefaultsKey.tokenExpiryTime, store: .appGroup) var tokenExpiryTime: Double = 0
    
    // MARK: - Private Properties
    private var refreshTimer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    
    // MARK: - Constants
    private let REFRESH_BUFFER_SECONDS = 900 // 15 minutes before expiry
    private let MIN_REFRESH_INTERVAL = 60 // Minimum 1 minute between refresh attempts
    private let MAX_REFRESH_INTERVAL = 1800 // Maximum 30 minutes between refresh attempts
    private let MAX_TOKEN_LIFETIME = 86400 // Maximum token lifetime of 24 hours
    private let MIN_TOKEN_LIFETIME = 60 // Minimum token lifetime of 1 minute
    
    // MARK: - Initialization
    static let shared = TokenManager()
    private init() {}
    
    // MARK: - Public Methods
    func initialize() async {
        print("TokenManager initializing")
        logTokenStatus()
        
        // If we don't have a refresh token, we're not logged in
        guard refreshToken.isNotBlank else {
            print("No refresh token available, not logged in")
            isLoggedIn = false
            return
        }
        
        if !checkTokenValidity() {
            print("Token validation failed, attempting refresh")
            await refreshAuth()
        } else {
            let currentTime = Date().timeIntervalSince1970
            let timeUntilExpiry = tokenExpiryTime - currentTime
            
            // If token is expired or about to expire, refresh it
            if timeUntilExpiry <= Double(REFRESH_BUFFER_SECONDS) {
                print("Token expires soon (\(Int(timeUntilExpiry))s), refreshing now")
                await refreshAuth()
            } else {
                print("Token is valid, proceeding with startup")
                isLoggedIn = true
                
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
        }
    }
    
    func handleAppActivation() async {
        print("TokenManager handling app activation")
        logTokenStatus()
        
        // End any background task
        if backgroundTask != .invalid {
            await UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
        
        // If we don't have a refresh token, we're definitely not logged in
        guard refreshToken.isNotBlank else {
            print("No refresh token available, not logged in")
            isLoggedIn = false
            return
        }
        
        // Only invalidate login state if we're certain the token is invalid
        if !checkTokenValidity() {
            print("Token validation failed on app activation, attempting refresh")
            // Don't set isLoggedIn to false yet, wait for refresh attempt
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
            // Token is valid, ensure we're logged in
            isLoggedIn = true
            
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
    }
    
    func handleAppBackground() {
        print("TokenManager handling app background")
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        // Start background task for token refresh
        startBackgroundTask()
    }
    
    func logout() {
        print("TokenManager handling logout")
        refreshTimer?.invalidate()
        refreshTimer = nil
        tokenExpiryTime = 0
        refreshToken = ""
        isLoggedIn = false
        isAppHoldScreen = false
    }
    
    func refreshAuth() async {
        print("Starting token refresh")
        await refreshAuthWithRetry(maxRetries: 3, initialDelay: 1.0)
        logTokenStatus()
    }
    
    func logTokenStatus() {
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
        - Token Valid: \(timeUntilExpiry > 0)
        - Refresh Token Present: \(refreshToken.isNotBlank)
        """)
    }
    
    // MARK: - Private Methods
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
    
    private func checkTokenValidity() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let timeUntilExpiry = tokenExpiryTime - currentTime
        
        // Check if we have a refresh token - this is the only case where we should immediately set logged out
        guard refreshToken.isNotBlank else {
            print("No refresh token available")
            isLoggedIn = false
            return false
        }
        
        // For other validation cases, just return false without changing login state
        // The refresh process will handle updating the login state
        
        // Validate the expiry time
        guard validateExpiryTime(Int(timeUntilExpiry)) else {
            print("Token has invalid expiry time, forcing refresh")
            return false
        }
        
        // Check if token is expired
        guard timeUntilExpiry > 0 else {
            print("Token is expired")
            return false
        }
        
        return true
    }
    
    private func setRefreshTimer(seconds: Int) {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(
            withTimeInterval: TimeInterval(seconds),
            repeats: false
        ) { [weak self] _ in
            Task { @Sendable [weak self] in
                await self?.refreshAuth()
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
                    isLoggedIn = true
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
                        Task { @Sendable [weak self] in
                            try? await Task.sleep(nanoseconds: 1_000_000_000) // Wait 1 second
                            await self?.refreshAuth()
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
                        logout()
                    } else {
                        // Only set logged out if we've exhausted all retries
                        isLoggedIn = false
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
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            print("Background task expiring")
            // Cleanup when background task expires
            if let self = self, self.backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(self.backgroundTask)
                self.backgroundTask = .invalid
            }
        }
        
        // Schedule background refresh
        Task { @Sendable [weak self] in
            guard let self = self else { return }
            
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
                await UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = .invalid
            }
        }
    }
} 
