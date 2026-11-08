import SwiftUI

struct ACChargeLimitView: View {
    @Environment(DataModel.self) var model
    
    @State private var acCurrentLimit: Int32 = 0
    @State private var isInitialSetup = true
    @State private var sendTask: Task<Void, Never>?
    @State private var holdTask: Task<Void, Never>?
    @State private var hasPendingChanges = false
    @State private var isHolding = false
    
    private let minimumAmps: Int32 = 10

    /// Station maximum. `energyAcCurrentLimit` is what the plugged-in charger can supply.
    /// 80 is only the car's own cap, used when the station has not reported one.
    private var chargerMaxAmps: Int32 {
        let energy = Int32(model.vehicle?.vehicleState.chargingState.energyAcCurrentLimit ?? 0)
        if energy > 0 {
            return min(80, energy)
        }
        return 80
    }

    private var buttonsDisabled: Bool {
        model.requestInProgress.contains(.acCurrentLimit) || model.allFunctionsDisable
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("AC Current Limiter")
                    .font(.headline)
                
                Spacer()
            }
            
            HStack(spacing: 20) {
                Image(systemName: "minus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(buttonsDisabled || acCurrentLimit <= minimumAmps ? Color.secondary : Color.active)
                    .onLongPressGesture(minimumDuration: 999, pressing: { isPressing in
                        guard !buttonsDisabled else { return }
                        if isPressing {
                            startHoldDetection(tapAmount: -1, holdAmount: -5)
                        } else {
                            handleRelease(tapAmount: -1)
                        }
                    }, perform: {})
                
                Spacer()

                if model.requestInProgress.contains(.acCurrentLimit) {
                    ProgressView()
                        .controlSize(.large)
                        .foregroundStyle(.active)
                        .transition(.scale)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(acCurrentLimit)A")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("/ \(chargerMaxAmps)A")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .monospacedDigit()
                }

                Spacer()
                
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(buttonsDisabled || acCurrentLimit >= chargerMaxAmps ? Color.secondary : Color.active)
                    .onLongPressGesture(minimumDuration: 999, pressing: { isPressing in
                        guard !buttonsDisabled else { return }
                        if isPressing {
                            startHoldDetection(tapAmount: 1, holdAmount: 5)
                        } else {
                            handleRelease(tapAmount: 1)
                        }
                    }, perform: {})
            }
            

        }
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            updateACLimitFromModel()
            
            Task {
                try? await Task.sleep(for: .milliseconds(100))
                isInitialSetup = false
            }
        }
        .onDisappear {
            sendTask?.cancel()
            holdTask?.cancel()
        }
        .onChange(of: model.vehicle?.vehicleState.chargingState.activeSessionAcCurrentLimit) { _, _ in
            if !isInitialSetup {
                updateACLimitFromModel()
            }
        }
        .onChange(of: model.vehicle?.vehicleState.chargingState.energyAcCurrentLimit) { _, _ in
            if !isInitialSetup {
                updateACLimitFromModel()
            }
        }
        .onChange(of: model.vehicle?.vehicleState.mobileAppReqStatus.acCurrentLimitReq) { _, _ in
            if !isInitialSetup {
                updateACLimitFromModel()
            }
        }
    }

    /// Accepted current for this session. A session value of 0 or above the station max
    /// means the car is still reporting its own 80A cap, so use the station max instead.
    private func acceptedAmps(session: Int32, stationMax: Int32) -> Int32 {
        let ceiling = stationMax > 0 ? min(80, stationMax) : 80
        if session <= 0 || session > ceiling {
            return ceiling
        }
        return max(minimumAmps, session)
    }
    
    private func updateACLimitFromModel() {
        if let vehicle = model.vehicle {
            let session = Int32(vehicle.vehicleState.chargingState.activeSessionAcCurrentLimit)
            let stationMax = Int32(vehicle.vehicleState.chargingState.energyAcCurrentLimit)
            let limit = acceptedAmps(session: session, stationMax: stationMax)
            
            print("ACChargeLimitView: Updating from model - session: \(session)A, station: \(stationMax)A, showing: \(limit)A")
            
            if isInitialSetup {
                acCurrentLimit = limit
            } else if !hasPendingChanges && !model.requestInProgress.contains(.acCurrentLimit) {
                if limit != acCurrentLimit {
                    acCurrentLimit = limit
                }
            }
        }
    }
    
    private func adjustACLimit(by amount: Int32) {
        let newTarget = max(minimumAmps, min(chargerMaxAmps, acCurrentLimit + amount))
        guard newTarget != acCurrentLimit && !isInitialSetup else { return }
        acCurrentLimit = newTarget
        hasPendingChanges = true
        print("ACChargeLimitView: Adjusted to \(newTarget)A")
    }
    
    private func scheduleSend() {
        sendTask?.cancel()
        sendTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            guard !model.requestInProgress.contains(.acCurrentLimit) else {
                print("ACChargeLimitView: Request already in progress, skipping send")
                hasPendingChanges = false
                return
            }
            print("ACChargeLimitView: Sending setACCurrLimit(\(acCurrentLimit))")
            model.setACCurrLimit(acCurrentLimit)
            hasPendingChanges = false
        }
    }
    
    private func startHoldDetection(tapAmount: Int32, holdAmount: Int32) {
        isHolding = false
        holdTask?.cancel()
        holdTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            isHolding = true
            adjustACLimit(by: holdAmount)
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(500))
                guard !Task.isCancelled else { return }
                adjustACLimit(by: holdAmount)
            }
        }
    }
    
    private func handleRelease(tapAmount: Int32) {
        holdTask?.cancel()
        holdTask = nil
        if !isHolding {
            adjustACLimit(by: tapAmount)
        }
        isHolding = false
        scheduleSend()
    }
}

#Preview {
    ACChargeLimitView()
        .environment(DataModel())
        .padding()
}
