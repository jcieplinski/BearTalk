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

    @AppStorage(DefaultsKey.userName) var userName: String = ""
    @AppStorage(DefaultsKey.password) var password: String = ""
    @AppStorage(DefaultsKey.carColor) var carColor: String = "eureka"

    var backgroundColors: [Color] {
        let top = Color(uiColor: .systemBackground)
        let bottom = Color.gray.opacity(0.55)

        return [top, bottom]
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
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }

                        loggedIn = true
                    }
                }

            } catch let error {
                print("Could not log in: \(error)")
            }
        }
    }

    func logOut() {
        Task {
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
