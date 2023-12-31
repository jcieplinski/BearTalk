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
//                    Button {
//                        authenticate()
//                    } label: {
//                        Text("Use FaceID")
//                    }
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
            .onAppear {
                Task {
                    do {
                        let passwordData = try KeyChain.readPassword(service: DefaultsKey.password, account: appState.userName)

                        appState.password = String(decoding: passwordData, as: UTF8.self)
                    } catch let error {
                        print("Error restoring password from KeyChain\(error)")
                    }
                }
//                DispatchQueue.main.async {
////                    if let receivedData = KeyChain.load(key: DefaultsKey.password) {
////
////                        let result = receivedData.to(type: String.self)
////                        appState.password = result
////                    }
//
//
//
//
//                }
            }
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // authentication has now completed
                if success {

                } else {
                    // there was a problem
                }
            }
        } else {
            // no biometrics
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppState())
}
