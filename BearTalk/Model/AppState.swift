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

    @AppStorage(DefaultsKey.userName) var userName: String = ""
    @Published var password: String = ""
    @AppStorage(DefaultsKey.carColor) var carColor: String = "eureka"

    var backgroundColors: [Color] {
        let top = Color(uiColor: .systemBackground)
        let bottom = Color.gray.opacity(0.55)

        return [top, bottom]
    }

    static var preview: AppState {
        let appState = AppState()
        appState.loggedIn = true
        appState.noCarMode = false
        appState.appHoldScreen = false

        return appState
    }

    func logIn() {
        guard userName.isNotBlank, password.isNotBlank else {
            return
        }

        Task {
            do {
                if let _ = try await BearAPI.logIn(
                    userName: userName,
                    password: password)
                    .loginResponse {

                    saveOrUpdatePassword()

                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }

                        loggedIn = true
                    }
                }

            } catch let error {
                print("Could not log in: \(error)")
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }

                    noCarMode = true
                }
            }
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
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }

                noCarMode = false
            }

            let loggedOut = try await BearAPI.logOut()

            if loggedOut {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    loggedIn = false
                }
            }
        }
    }
}
