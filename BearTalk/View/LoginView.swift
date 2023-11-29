//
//  LoginView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @AppStorage(DefaultsKey.userName) var userName: String = ""

    @AppStorage(DefaultsKey.password) var password: String = ""

    var body: some View {
        VStack(spacing: 22) {
            TextField("UserName", text: $userName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            Button {
                logIn()
            } label: {
                Text("Log In")
            }

        }
        .padding()
    }

    private func logIn() {
        guard userName.isNotBlank, password.isNotBlank else {
            return
        }

        Task {
            do {
                if let _ = try await BearAPI.logIn(
                    userName: userName,
                    password: password)
                    .loginResponse {
                    appState.loggedIn = true
                }

            } catch let error {
                print("Could not log in: \(error)")
            }
        }
    }
}

#Preview {
    LoginView()
}
