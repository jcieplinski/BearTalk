import SwiftUI
import Observation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) var appState: AppState
    let colorSchemeManager: ColorSchemeManager = .shared
    @State private var showLogOutWarning = false
    
    private var currentScheme: AppColorScheme {
        let rawValue = UserDefaults.appGroup.integer(forKey: DefaultsKey.colorScheme)
        return AppColorScheme(rawValue: rawValue) ?? .system
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section("Appearance") {
                    Menu {
                        Button {
                            colorSchemeManager.setScheme(.system)
                        } label: {
                            HStack {
                                Text("System")
                                if currentScheme == .system {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button {
                            colorSchemeManager.setScheme(.light)
                        } label: {
                            HStack {
                                Text("Light")
                                if currentScheme == .light {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button {
                            colorSchemeManager.setScheme(.dark)
                        } label: {
                            HStack {
                                Text("Dark")
                                if currentScheme == .dark {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text("Color Scheme")
                            Spacer()
                            Text(currentScheme == .system ? "System" : currentScheme == .light ? "Light" : "Dark")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showLogOutWarning = true
                    } label: {
                        Label("Log Out", systemImage: "person.circle")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Are you Sure?", isPresented: $showLogOutWarning) {
                Button("Log Out", role: .destructive) {
                    appState.logOut()
                }
                Button("Cancel", role: .cancel) {
                    showLogOutWarning = false
                }
            } message: {
                Text("Do you wish to log out of your Lucid account?")
            }
            .preferredColorScheme(colorSchemeManager.currentScheme)
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppState())
}
