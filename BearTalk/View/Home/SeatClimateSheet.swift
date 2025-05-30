import SwiftUI

struct SeatClimateSheet: View {
    @Environment(DataModel.self) var model
    @Environment(\.dismiss) var dismiss
    
    let modalPresented: Bool
    
    var body: some View {
        NavigationStack {
            @Bindable var model = model
            
            VStack(spacing: 16) {
                // All On/Off Buttons
                HStack(spacing: 20) {
                    Button {
                        var seats: [SeatAssignment] = []
                        
                        if model.hasFrontSeatHeating {
                            seats.append(contentsOf: [
                                .driverHeatBackrestZone1(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .driverHeatBackrestZone3(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .driverHeatCushionZone2(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .driverHeatCushionZone4(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerHeatBackrestZone1(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerHeatBackrestZone3(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerHeatCushionZone2(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerHeatCushionZone4(mode: SeatClimateMode(levelInt: model.seatClimateLevel))
                            ])
                        }
                        
                        if model.hasFrontSeatVentilation {
                            seats.append(contentsOf: [
                                .driverVentCushion(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .driverVentBackrest(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerVentCushion(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .frontPassengerVentBackrest(mode: SeatClimateMode(levelInt: model.seatClimateLevel))
                            ])
                        }
                        
                        if model.hasRearSeatHeating {
                            seats.append(contentsOf: [
                                .rearPassengerHeatLeft(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .rearPassengerHeatCenter(mode: SeatClimateMode(levelInt: model.seatClimateLevel)),
                                .rearPassengerHeatRight(mode: SeatClimateMode(levelInt: model.seatClimateLevel))
                            ])
                        }
                        
                        model.setSeatClimate(seats: seats)
                    } label: {
                        Text("All On")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.active)
                    .disabled(model.requestInProgress.contains(.driverSeatHeat) || 
                             (!model.hasFrontSeatHeating && !model.hasFrontSeatVentilation && !model.hasRearSeatHeating))
                    
                    Button {
                        model.setSeatClimate(
                            seats: [
                                .driverHeatBackrestZone1(mode: .off),
                                .driverHeatBackrestZone3(mode: .off),
                                .driverHeatCushionZone2(mode: .off),
                                .driverHeatCushionZone4(mode: .off),
                                .driverVentCushion(mode: .off),
                                .driverVentBackrest(mode: .off),
                                .frontPassengerHeatBackrestZone1(mode: .off),
                                .frontPassengerHeatBackrestZone3(mode: .off),
                                .frontPassengerHeatCushionZone2(mode: .off),
                                .frontPassengerHeatCushionZone4(mode: .off),
                                .frontPassengerVentCushion(mode: .off),
                                .frontPassengerVentBackrest(mode: .off),
                                .rearPassengerHeatLeft(mode: .off),
                                .rearPassengerHeatCenter(mode: .off),
                                .rearPassengerHeatRight(mode: .off)
                            ]
                        )
                    } label: {
                        Text("All Off")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.inactive)
                    .disabled(model.requestInProgress.contains(.driverSeatHeat))
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
                    .onChange(of: model.seatClimateLevel) { _, newLevel in
                        // Only proceed if any seats are on
                        guard model.frontDriverSeatHeatOn || model.frontDriverSeatVentOn ||
                              model.frontPassengerSeatHeatOn || model.frontPassengerSeatVentOn ||
                              model.rearleftSeatHeatOn || model.rearCenterHeatOn || model.rearRightSeatHeatOn else {
                            return
                        }
                        
                        // Build array of currently active seats with new level
                        var activeSeats: [SeatAssignment] = []
                        
                        if model.frontDriverSeatHeatOn {
                            activeSeats.append(contentsOf: [
                                .driverHeatBackrestZone1(mode: SeatClimateMode(levelInt: newLevel)),
                                .driverHeatBackrestZone3(mode: SeatClimateMode(levelInt: newLevel)),
                                .driverHeatCushionZone2(mode: SeatClimateMode(levelInt: newLevel)),
                                .driverHeatCushionZone4(mode: SeatClimateMode(levelInt: newLevel))
                            ])
                        }
                        
                        if model.frontDriverSeatVentOn {
                            activeSeats.append(contentsOf: [
                                .driverVentCushion(mode: SeatClimateMode(levelInt: newLevel)),
                                .driverVentBackrest(mode: SeatClimateMode(levelInt: newLevel))
                            ])
                        }
                        
                        if model.frontPassengerSeatHeatOn {
                            activeSeats.append(contentsOf: [
                                .frontPassengerHeatBackrestZone1(mode: SeatClimateMode(levelInt: newLevel)),
                                .frontPassengerHeatBackrestZone3(mode: SeatClimateMode(levelInt: newLevel)),
                                .frontPassengerHeatCushionZone2(mode: SeatClimateMode(levelInt: newLevel)),
                                .frontPassengerHeatCushionZone4(mode: SeatClimateMode(levelInt: newLevel))
                            ])
                        }
                        
                        if model.frontPassengerSeatVentOn {
                            activeSeats.append(contentsOf: [
                                .frontPassengerVentCushion(mode: SeatClimateMode(levelInt: newLevel)),
                                .frontPassengerVentBackrest(mode: SeatClimateMode(levelInt: newLevel))
                            ])
                        }
                        
                        if model.rearleftSeatHeatOn {
                            activeSeats.append(.rearPassengerHeatLeft(mode: SeatClimateMode(levelInt: newLevel)))
                        }
                        
                        if model.rearCenterHeatOn {
                            activeSeats.append(.rearPassengerHeatCenter(mode: SeatClimateMode(levelInt: newLevel)))
                        }
                        
                        if model.rearRightSeatHeatOn {
                            activeSeats.append(.rearPassengerHeatRight(mode: SeatClimateMode(levelInt: newLevel)))
                        }
                        
                        // Only call setSeatClimate if we have active seats
                        if !activeSeats.isEmpty {
                            model.setSeatClimate(seats: activeSeats)
                        }
                    }
                }
                .padding(.bottom, 22)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Driver")
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    }
                    
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Passenger")
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    }
                }
                
                // Front Seats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .driverHeatCushionZone2(mode: model.frontDriverSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .driverHeatCushionZone4(mode: model.frontDriverSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .driverHeatBackrestZone1(mode: model.frontDriverSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .driverHeatBackrestZone3(mode: model.frontDriverSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel))
                                ]
                            )
                        } label: {
                            ControlButtonCore(
                                controlType: .seatClimate,
                                isActive: model.frontDriverSeatHeatOn
                            )
                        }
                        .disabled(model.requestInProgress.contains(.driverSeatHeat) || !model.hasFrontSeatHeating)
                        
                        if model.requestInProgress.contains(.driverSeatHeat) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.frontDriverSeatHeatOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .driverVentCushion(mode: model.frontDriverSeatVentOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .driverVentBackrest(mode: model.frontDriverSeatVentOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                ]
                            )
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
                            .tint(model.frontDriverSeatVentOn ? .active : .inactive)
                        }
                        .disabled(model.requestInProgress.contains(.driverSeatVent) || !model.hasFrontSeatVentilation)
                        
                        if model.requestInProgress.contains(.driverSeatVent) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.frontDriverSeatVentOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .frontPassengerHeatCushionZone2(mode: model.frontPassengerSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .frontPassengerHeatCushionZone4(mode: model.frontPassengerSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .frontPassengerHeatBackrestZone1(mode: model.frontPassengerSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .frontPassengerHeatBackrestZone3(mode: model.frontPassengerSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel))
                                ]
                            )
                        } label: {
                            ControlButtonCore(
                                controlType: .seatClimate,
                                isActive: model.frontPassengerSeatHeatOn
                            )
                        }
                        .disabled(model.requestInProgress.contains(.passengerSeatHeat) || !model.hasFrontSeatHeating)
                        
                        if model.requestInProgress.contains(.passengerSeatHeat) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.frontPassengerSeatHeatOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .frontPassengerVentCushion(mode: model.frontPassengerSeatVentOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                    .frontPassengerVentBackrest(mode: model.frontPassengerSeatVentOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel)),
                                ]
                            )
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
                            .tint(model.frontPassengerSeatVentOn ? .active : .inactive)
                        }
                        .disabled(model.requestInProgress.contains(.passengerSeatVent) || !model.hasFrontSeatVentilation)
                        
                        if model.requestInProgress.contains(.passengerSeatVent) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.frontPassengerSeatVentOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Left")
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Center")
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 13)
                            .frame(maxHeight: 44)
                            .foregroundStyle(.ultraThinMaterial)
                        
                        Text("Rear Right")
                            .dynamicTypeSize(...DynamicTypeSize.xLarge)
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
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .rearPassengerHeatLeft(mode: model.rearleftSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel))
                                ]
                            )
                        } label: {
                            ControlButtonCore(
                                controlType: .seatClimate,
                                isActive: model.rearleftSeatHeatOn
                            )
                        }
                        .disabled(model.requestInProgress.contains(.rearLeftSeatHeat) || !model.hasRearSeatHeating)
                        
                        if model.requestInProgress.contains(.rearLeftSeatHeat) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.rearleftSeatHeatOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    
                    // Rear Middle
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .rearPassengerHeatCenter(mode: model.rearCenterHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel))
                                ]
                            )
                        } label: {
                            ControlButtonCore(
                                controlType: .seatClimate,
                                isActive: model.rearCenterHeatOn
                            )
                        }
                        .disabled(model.requestInProgress.contains(.rearCenterSeatHeat) || !model.hasRearSeatHeating)
                        
                        if model.requestInProgress.contains(.rearCenterSeatHeat) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.rearCenterHeatOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                    
                    // Rear Right
                    ZStack {
                        Button {
                            model.setSeatClimate(
                                seats: [
                                    .rearPassengerHeatRight(mode: model.rearRightSeatHeatOn ? .off : SeatClimateMode(levelInt: model.seatClimateLevel))
                                ]
                            )
                        } label: {
                            ControlButtonCore(
                                controlType: .seatClimate,
                                isActive: model.rearRightSeatHeatOn
                            )
                        }
                        .disabled(model.requestInProgress.contains(.rearRightSeatHeat) || !model.hasRearSeatHeating)
                        
                        if model.requestInProgress.contains(.rearRightSeatHeat) {
                            ProgressView()
                                .fontWeight(.thin)
                                .controlSize(.large)
                                .foregroundStyle(.active)
                        }
                    }
                    .overlay(alignment: .bottomTrailing) {
                        if model.rearRightSeatHeatOn {
                            Text("\(model.seatClimateLevel)")
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .frame(width: 20, height: 20)
                                .background(Circle().fill(.active))
                                .offset(x: 10, y: 10)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Seat Climate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if modalPresented {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .toolbarVisibility(modalPresented ? .hidden : .automatic, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    SeatClimateSheet(modalPresented: true)
        .environment(DataModel())
}
