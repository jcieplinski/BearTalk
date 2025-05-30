import SwiftUI

struct ControlAlertView: View {
    @Environment(DataModel.self) var model
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var pendingControlType: ControlType?
    
    var body: some View {
        EmptyView()
            .onReceive(NotificationCenter.default.publisher(for: .showControlAlert)) { notification in
                if let userInfo = notification.userInfo,
                   let controlType = userInfo["controlType"] as? ControlType,
                   let title = userInfo["title"] as? String,
                   let message = userInfo["message"] as? String {
                    alertTitle = title
                    alertMessage = message
                    pendingControlType = controlType
                    showingAlert = true
                }
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("Cancel", role: .cancel) {
                    pendingControlType = nil
                }
                Button("OK") {
                    if let controlType = pendingControlType {
                        // Re-post the control action without showing alert
                        model.showAlertsBeforeOpenActions = false
                        model.handleControlAction(controlType)
                        model.showAlertsBeforeOpenActions = true
                    }
                    pendingControlType = nil
                }
            } message: {
                Text(alertMessage)
            }
    }
} 