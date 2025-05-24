//
//  AppState.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var loggedIn: Bool = false
    @Published var appHoldScreen: Bool = true
    @Published var selectedTab: AppTab = .home

    @Published var noCarMode: Bool = false

    @AppStorage(DefaultsKey.userName, store: .appGroup) var userName: String = ""
    @Published var password: String = ""
    @AppStorage(DefaultsKey.carColor, store: .appGroup) var carColor: String = "eureka"

    var backgroundColors: [Color] {
        let top = Color(uiColor: .systemBackground)
        let bottom = Color.gray.opacity(0.35)

        return [top, bottom]
    }

    static var preview: AppState {
        let appState = AppState()
        appState.loggedIn = true
        appState.noCarMode = false
        appState.appHoldScreen = false

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
                
                Task { @MainActor in
                    loggedIn = true
                }
                
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
            
            Task { @MainActor in
                loggedIn = false
            }
            
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
                Task { @MainActor in
                     loggedIn = false
                }
            }
        }
    }
}
