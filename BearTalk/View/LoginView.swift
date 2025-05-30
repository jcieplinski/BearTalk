//
//  LoginView.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import SwiftUI
import LocalAuthentication

struct LoginView: View {
    @Environment(AppState.self) var appState: AppState
    @Environment(DataModel.self) var model: DataModel
    private let tokenManager = TokenManager.shared

    @FocusState var focused: FocusableField?
    @State var showingProgress: Bool = false
    @AppStorage(DefaultsKey.useFaceID, store: .appGroup) private var useFaceID: Bool = false
    @State private var showingFaceIDError: Bool = false
    @State private var faceIDError: String = ""
    @State private var hasAttemptedFaceID: Bool = false

    var body: some View {
        NavigationStack {
            @Bindable var appState = appState
            VStack(spacing: 22) {
                List {
                    Text("Log in to your lucidmotors.com account to begin.")
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .padding([.top, .leading, .trailing])
                    
                    if !useFaceID {
                        Capsule(style: .continuous)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .overlay {
                                TextField("username", text: $appState.userName)
                                    .textFieldStyle(.plain)
                                    .textContentType(.emailAddress)
                                    .focused($focused, equals: .userName)
                                    .padding()
                                    .submitLabel(.next)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                                    .textInputAutocapitalization(.never)
                                    .onSubmit {
                                        focused = .password
                                    }
                            }
                        
                        Capsule(style: .continuous)
                            .foregroundStyle(Color.gray.opacity(0.3))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .overlay {
                                SecureField("password", text: $appState.password)
                                    .textFieldStyle(.plain)
                                    .textContentType(.password)
                                    .focused($focused, equals: .password)
                                    .padding()
                                    .onSubmit {
                                        focused = nil
                                    }
                            }
                    }
                    
                    if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
                        Toggle(isOn: $useFaceID) {
                            Label("Use Face ID", systemImage: "faceid")
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                        .onChange(of: useFaceID) { oldValue, newValue in
                            if newValue {
                                hasAttemptedFaceID = false
                            }
                        }
                        .disabled(!useFaceID && appState.userName.isEmpty || appState.password.isEmpty)
                    }
                    
                    SceneKitViewLogin { view in
                        DispatchQueue.main.async {
                            // Configure view for transparency
                            view.backgroundColor = .clear
                            view.scene?.background.contents = nil
                        }
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .tint(.accentColor)
                    .padding(.top, 44)
                    Text("Your username and password will remain between you and Lucid Motors. This app does not send any authorization information to the app creators.")
                        .font(.caption)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.horizontal)
                    if showingProgress {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                }
                .scrollContentBackground(.hidden)
                .scrollBounceBehavior(.basedOnSize)
                .listStyle(.plain)
                .animation(.spring(duration: 0.3), value: useFaceID)
                .animation(.spring(duration: 0.3), value: hasAttemptedFaceID)
                .safeAreaInset(edge: .bottom, content: {
                    Button {
                        showingProgress = true
                        Task { @MainActor in
                            if useFaceID && !hasAttemptedFaceID {
                                hasAttemptedFaceID = true
                                await authenticateWithFaceID()
                            } else {
                                await performLogin()
                            }
                        }
                    } label: {
                        Text(useFaceID && !hasAttemptedFaceID ? "Log In with Face ID" : "Log In")
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity)
                            .frame(minHeight: 28)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                })
            }
            .navigationTitle("Welcome")
            .background(
                LinearGradient(gradient: Gradient(colors: appState.backgroundColors), startPoint: .top, endPoint: .bottom)
            )
            .alert("Face ID Error", isPresented: $showingFaceIDError) {
                Button("OK", role: .cancel) { 
                    if useFaceID {
                        useFaceID = false
                    }
                }
            } message: {
                Text(faceIDError)
            }
            .onAppear {
                if !useFaceID {
                    Task {
                        do {
                            let passwordData = try KeyChain.readPassword(service: DefaultsKey.password, account: appState.userName)
                            appState.password = String(decoding: passwordData, as: UTF8.self)
                        } catch let error {
                            print("Error restoring password from KeyChain\(error)")
                        }
                    }
                }
            }
        }
    }

    private func authenticateWithFaceID() async {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            faceIDError = "Face ID is not available on this device"
            showingFaceIDError = true
            useFaceID = false
            hasAttemptedFaceID = false
            return
        }
        
        do {
            let reason = "Log in to your Lucid Motors account"
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            
            if success {
                // If Face ID succeeds, we need to ensure we have credentials
                if appState.userName.isBlank || appState.password.isBlank {
                    // Try to restore credentials from KeyChain
                    do {
                        let passwordData = try KeyChain.readPassword(service: DefaultsKey.password, account: appState.userName)
                        appState.password = String(decoding: passwordData, as: UTF8.self)
                    } catch {
                        faceIDError = "Could not restore saved credentials"
                        showingFaceIDError = true
                        hasAttemptedFaceID = false
                        return
                    }
                }
                
                await performLogin()
            } else {
                hasAttemptedFaceID = false
            }
        } catch {
            faceIDError = error.localizedDescription
            showingFaceIDError = true
            hasAttemptedFaceID = false
        }
    }
    
    private func performLogin() async {
        do {
            let response = try await BearAPI.logIn(userName: appState.userName, password: appState.password)
            if let loginResponse = response.loginResponse {
                // Ensure we have a valid refresh token
                guard loginResponse.sessionInfo.refreshToken.isNotBlank else {
                    print("Login response missing refresh token")
                    return
                }
                
                // Set the token expiry time based on the response
                TokenManager.shared.tokenExpiryTime = Date().timeIntervalSince1970 + Double(loginResponse.sessionInfo.expiryTimeSec)
                TokenManager.shared.refreshToken = loginResponse.sessionInfo.refreshToken
                
                // Initialize token manager and set login state
                await TokenManager.shared.initialize()
                TokenManager.shared.isLoggedIn = true
                
                // Update the model with user profile
                model.userProfile = loginResponse.userProfile
                
                // Update vehicle identifiers from login response
                let vehicleEntities = loginResponse.userVehicleData.map { vehicle -> VehicleIdentifierEntity in
                    return VehicleIdentifierEntity(id: vehicle.vehicleId, nickname: vehicle.vehicleConfig.nickname)
                }
                try await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).add(vehicleEntities)
                
                // Update the vehicleIdentifiers property
                model.vehicleIdentifiers = try? await VehicleIdentifierHandler(modelContainer: BearAPI.sharedModelContainer).fetch()
                
                // Start refreshing vehicle data
                model.startRefreshing()
            }
        } catch {
            print("Login failed: \(error)")
        }
        showingProgress = false
    }
}

#Preview {
    LoginView()
        .environment(AppState())
}
