import SwiftUI

struct SeatClimateSheet: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            @Bindable var model = model
            
            VStack(spacing: 16) {
                // All On/Off Buttons
                HStack(spacing: 20) {
                    Button {
                        // TODO: Implement all seats on
                    } label: {
                        Label("All On", systemImage: "flame.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.active)
                    
                    Button {
                        // TODO: Implement all seats off
                    } label: {
                        Label("All Off", systemImage: "flame.slash.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.inactive)
                }
                .padding(.horizontal)
                
                // Level Picker
                VStack(spacing: 8) {
                    Text("Level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Picker("Level", selection: $model.seatClimateLevel) {
                        Text("1").tag(1)
                        Text("2").tag(2)
                        Text("3").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                .padding(.bottom, 22)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Driver")
                    }
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Passenger")
                    }
                }
                
                // Front Seats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    Button {
                        // TODO: Implement driver heat
                    } label: {
                        ControlButtonCore(
                            controlType: .seatClimate,
                            isActive: model.frontDriverSeatHeatOn
                        )
                    }
                    
                    Button {
                        // TODO: Implement driver ventilation
                    } label: {
                        Label {
                            Text("Front Driver Ventilation")
                        } icon: {
                            Image(model.frontDriverSeatVentOn ? "seatVentOn" : "seatVentOff")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 44, maxHeight: 44)
                        }
                        .labelStyle(.iconOnly)
                        
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        )
                        .tint(model.frontDriverSeatVentOn ? .activeCool : .inactive)
                        .disabled(model.requestInProgress.contains(.seatClimate))
                    }
                    
                    Button {
                        // TODO: Implement passenger heat
                    } label: {
                        ControlButtonCore(
                            controlType: .seatClimate,
                            isActive: model.frontPassengerSeatHeatOn
                        )
                    }
                    
                    Button {
                        // TODO: Implement passenger ventilation
                    } label: {
                        Label {
                            Text("Front Passenger Ventilation")
                        } icon: {
                            Image(model.frontPassengerSeatVentOn ? "seatVentOn" : "seatVentOff")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 44, maxHeight: 44)
                        }
                        .labelStyle(.iconOnly)
                        
                        .padding(4)
                        .background(
                            RoundedRectangle(cornerRadius: 13)
                                .stroke(style: StrokeStyle(lineWidth: 1))
                        )
                        .tint(model.frontPassengerSeatVentOn ? .activeCool : .inactive)
                        .disabled(model.requestInProgress.contains(.seatClimate))
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Left")
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Center")
                    }
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Right")
                    }
                }
                .padding(.top, 12)
                
                // Rear Seats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    // Rear Left
                    Button {
                        // TODO: Implement rear left heat
                    } label: {
                        ControlButtonCore(
                            controlType: .seatClimate,
                            isActive: model.rearleftSeatHeatOn
                        )
                    }
                    
                    // Rear Middle
                    Button {
                        // TODO: Implement rear middle heat
                    } label: {
                        ControlButtonCore(
                            controlType: .seatClimate,
                            isActive: model.rearCenterHeatOn
                        )
                    }
                    
                    // Rear Right
                    Button {
                        // TODO: Implement rear right heat
                    } label: {
                        ControlButtonCore(
                            controlType: .seatClimate,
                            isActive: model.rearRightSeatHeatOn
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Seat Climate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    SeatClimateSheet()
        .environment(DataModel())
}
