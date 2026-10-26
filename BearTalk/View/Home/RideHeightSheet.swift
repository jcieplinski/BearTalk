//
//  RideHeightSheet.swift
//  BearTalk
//

import SwiftUI

struct RideHeightSheet: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) private var dismiss

    private var isCharging: Bool {
        model.vehicle?.vehicleState.chargingState.chargeState == .charging
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(RideHeight.adjustableLevels) { level in
                        Button {
                            model.setRideHeight(level)
                            dismiss()
                        } label: {
                            HStack {
                                Text(level.title)
                                Spacer()
                                if model.rideHeight == level {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.active)
                                }
                            }
                        }
                        .disabled(isCharging || model.allFunctionsDisable)
                    }
                } footer: {
                    Text("Stand next to the car. The car also refuses this while charging, towing, or on a flatbed.")
                }
            }
            .navigationTitle("Ride Height")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
