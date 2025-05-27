//
//  AppState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import Observation

@Observable
final class ColorSchemeManager {
    static let shared = ColorSchemeManager()
    
    private(set) var currentScheme: ColorScheme?
    
    private init() {
        // Initialize from UserDefaults
        let rawValue = UserDefaults.appGroup.integer(forKey: DefaultsKey.colorScheme)
        updateScheme(from: rawValue)
    }
    
    func setScheme(_ scheme: AppColorScheme) {
        UserDefaults.appGroup.set(scheme.rawValue, forKey: DefaultsKey.colorScheme)
        updateScheme(from: scheme.rawValue)
    }
    
    private func updateScheme(from rawValue: Int) {
        switch AppColorScheme(rawValue: rawValue) {
        case .system:
            currentScheme = nil
        case .light:
            currentScheme = .light
        case .dark:
            currentScheme = .dark
        case .none:
            currentScheme = nil
        }
    }
}

@Observable final class AppState {
    var selectedTab: AppTab = .home
    var noCarMode: Bool = false
    
    var colorSchemeManager: ColorSchemeManager { .shared }
    
    @ObservationIgnored @AppStorage(DefaultsKey.userName, store: .appGroup) var userName: String = ""
    var password: String = ""
    @ObservationIgnored @AppStorage(DefaultsKey.carColor, store: .appGroup) var carColor: String = "eureka"

    public init() {}

    var backgroundColors: [Color] {
        let top = Color(uiColor: .systemBackground)
        let bottom = Color.gray.opacity(0.25)

        return [top, bottom]
    }

    static var preview: AppState {
        let appState = AppState()
        appState.noCarMode = false
        return appState
    }

    func logIn() async throws -> UserProfile? {
        guard userName.isNotBlank, password.isNotBlank else {
            return nil
        }

        do {
            if let response = try await BearAPI.logIn(
                userName: userName,
                password: password)
                .loginResponse {
                
                saveOrUpdatePassword()
                
                let userProfile: UserProfile? = UserProfile(
                    email: response.userProfile.email,
                    locale: response.userProfile.locale,
                    username: response.userProfile.username,
                    photoUrl: response.userProfile.photoUrl,
                    firstName: response.userProfile.firstName,
                    lastName: response.userProfile.locale,
                    emaId: response.userProfile.emaId
                )
                
                return userProfile
            }
            
            return nil
        } catch let error {
            print("Could not log in: \(error)")
            return nil
        }
    }

    func saveOrUpdatePassword() {
        let passwordData = Data(password.utf8)

        do {
            let savedPasswordData = try KeyChain.readPassword(service: DefaultsKey.password, account: userName)
            let savedPassword = String(decoding: savedPasswordData, as: UTF8.self)

            if savedPassword != password {
                try KeyChain.update(password: passwordData, service: DefaultsKey.password, account: userName)
            }
        } catch let error {
            print("Error reading password \(error)")
            if let keychainError = error as? KeyChain.KeychainError {
                switch keychainError {
                case .itemNotFound:
                    do {
                        try KeyChain.save(password: passwordData, service: DefaultsKey.password, account: userName)
                    } catch let error {
                        print("Error saving password \(error)")
                    }
                case .duplicateItem, .invalidItemFormat, .unexpectedStatus(_):
                    // Just don't bother at this point.
                    break
                }
            }
        }
    }

    func logOut() {
        Task {
            Task { @MainActor in
                noCarMode = false
            }

            let loggedOut = try await BearAPI.logOut()
            if loggedOut {
                TokenManager.shared.logout()
            }
        }
    }
}
