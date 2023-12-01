//
//  LoginView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @EnvironmentObject private var appState: AppState

    @FocusState var focused: FocusableField?
    @State var showingProgress: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                List {
                    Text("Log in to your lucidmotors.com account to begin.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .overlay {
                            TextField("UserName", text: $appState.userName)
                                .textFieldStyle(.plain)
                                .textContentType(.emailAddress)
                                .focused($focused, equals: .userName)
                                .padding()
                                .submitLabel(.next)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                .onSubmit {
                                    focused = .password
                                }
                        }

                    Capsule(style: .continuous)
                        .foregroundStyle(Color.gray.opacity(0.3))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .overlay {
                            SecureField("Password", text: $appState.password)
                                .textFieldStyle(.plain)
                                .textContentType(.password)
                                .focused($focused, equals: .password)
                                .padding()
                                .onSubmit {
                                    focused = nil
                                }
                        }
                    Image(appState.carColor)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .frame(width: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.top)
                    Button {
                        appState.logIn()
                        showingProgress = true
                    } label: {
                        Text("Log In")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 28)
                    }
                    .buttonStyle(.borderedProminent)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .tint(.accentColor)
                    .frame(maxWidth: .infinity)
                    .padding(.top)
                    Text("Your username and password will remain between you and Lucid Motors. This app does not send any authorization information to the app creators.")
                        .font(.caption)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    if showingProgress {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
                .padding()

            }
            .padding([.top, .leading, .trailing])
            .navigationTitle("Welcome")
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
