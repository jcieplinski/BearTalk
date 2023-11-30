//
//  LoginView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                List {
                    Image(appState.carColor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Text("Log in to your Lucid.com account to begin.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .overlay {
                            TextField("UserName", text: $appState.userName)
                                .textFieldStyle(.plain)
                                .textContentType(.username)
                                .padding()
                        }

                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .overlay {
                            SecureField("Password", text: $appState.password)
                                .textFieldStyle(.plain)
                                .textContentType(.password)
                                .padding()
                        }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .padding()
                Spacer()
                Button {
                    appState.logIn()
                } label: {
                    Text("Log In")
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)

            }
            .padding()
            .navigationTitle("Log In")
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
