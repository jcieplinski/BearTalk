//
//  Bear_Talk_Widget_Extension.swift
//  Bear Talk Widget Extension
//
//  Created by Joe Cieplinski on 5/30/25.
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(
            date: Date(),
            configuration: BearWidgetIntent(),
            nickname: "My Lucid",
            vehicleState: nil,
            snapshotData: nil
        )
    }

    func snapshot(for configuration: BearWidgetIntent, in context: Context) async -> SimpleEntry {
        let _ = try? await BearAPI.refreshToken()
        let vehicles = try? await BearAPI.fetchVehicles()
        
        let vehicle = vehicles?.first(where: { $0.vehicleId == configuration.vehicle?.id }) ?? vehicles?.first
        
        // Get the snapshot data using VehicleIdentifierHandler
        var snapshotData: Data?
        if let vehicleId = vehicle?.vehicleId {
            snapshotData = try? await VehicleIdentifierSnapshotHandler(modelContainer: BearAPI.sharedModelContainer).fetchSnapshotData(for: vehicleId)
        }
        
        return SimpleEntry(
            date: Date(),
            configuration: configuration,
            nickname: vehicle?.vehicleConfig.nickname ?? "",
            vehicleState: vehicle?.vehicleState,
            snapshotData: snapshotData
        )
    }
    
    func timeline(for configuration: BearWidgetIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let _ = try? await BearAPI.refreshToken()
        let vehicles = try? await BearAPI.fetchVehicles()
        
        let vehicle = vehicles?.first(where: { $0.vehicleId == configuration.vehicle?.id }) ?? vehicles?.first
        
        // Get the snapshot data using VehicleIdentifierHandler
        var snapshotData: Data?
        if let vehicleId = vehicle?.vehicleId {
            snapshotData = try? await VehicleIdentifierSnapshotHandler(modelContainer: BearAPI.sharedModelContainer).fetchSnapshotData(for: vehicleId)
        }

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                nickname: vehicle?.vehicleConfig.nickname ?? "",
                vehicleState: vehicle?.vehicleState,
                snapshotData: snapshotData
            )
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: BearWidgetIntent
    let nickname: String
    let vehicleState: VehicleState?
    let snapshotData: Data?
}

struct Bear_Talk_Widget_ExtensionEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        if let vehicleState = entry.vehicleState {
            switch family {
            case .systemSmall:
                VStack(spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Spacer(minLength: 1)
                        
                        if entry.nickname.isNotBlank {
                            Text(entry.nickname)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.caption)
                        }
                        
                        Text("\(vehicleState.batteryState.chargePercent.rounded().stringWithLocale())%")
                            .font(.title)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    HStack {
                        if let controlOne = entry.configuration.controlTypeOne {
                            WidgetControlButton(controlType: controlOne, isActive: isActive(for: controlOne), intent: intent(for: controlOne))
                        }
                        
                        if let controlTwo = entry.configuration.controlTypeTwo {
                            WidgetControlButton(controlType: controlTwo, isActive: isActive(for: controlTwo), intent: intent(for: controlTwo))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        if let controlThree = entry.configuration.controlTypeThree {
                            WidgetControlButton(controlType: controlThree, isActive: isActive(for: controlThree), intent: intent(for: controlThree))
                        }
                        
                        if let controlFour = entry.configuration.controlTypeFour {
                            WidgetControlButton(controlType: controlFour, isActive: isActive(for: controlFour), intent: intent(for: controlFour))
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
                .padding()
            
            case .systemMedium:
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        VStack {
                            if entry.nickname.isNotBlank {
                                Text(entry.nickname)
                                    .font(.headline)
                            }
                            
                            Text("\(vehicleState.batteryState.chargePercent.rounded().stringWithLocale())%")
                                .font(.title)
                        }
                        
                        if let snapshotData = entry.snapshotData,
                           let uiImage = UIImage(data: snapshotData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: 400, maxHeight: 80)
                        }
                    }
                    
                    HStack {
                        if let controlOne = entry.configuration.controlTypeOne {
                            WidgetControlButton(controlType: controlOne, isActive: isActive(for: controlOne), intent: intent(for: controlOne))
                        }
                        
                        if let controlTwo = entry.configuration.controlTypeTwo {
                            WidgetControlButton(controlType: controlTwo, isActive: isActive(for: controlTwo), intent: intent(for: controlTwo))
                        }
                        
                        if let controlThree = entry.configuration.controlTypeThree {
                            WidgetControlButton(controlType: controlThree, isActive: isActive(for: controlThree), intent: intent(for: controlThree))
                        }
                        
                        if let controlFour = entry.configuration.controlTypeFour {
                            WidgetControlButton(controlType: controlFour, isActive: isActive(for: controlFour), intent: intent(for: controlFour))
                        }
                    }
                }
                .padding()
            
            case .systemLarge:
                VStack(spacing: 0) {
                    if let snapshotData = entry.snapshotData,
                       let uiImage = UIImage(data: snapshotData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: 500, maxHeight: 300)
                    }
                    
                    if entry.nickname.isNotBlank {
                        Text(entry.nickname)
                            .font(.headline)
                    }
                    
                    Text("\(vehicleState.batteryState.chargePercent.rounded().stringWithLocale())%")
                        .font(.title)
                    
                    HStack {
                        if let controlOne = entry.configuration.controlTypeOne {
                            WidgetControlButton(controlType: controlOne, isActive: isActive(for: controlOne), intent: intent(for: controlOne))
                        }
                        
                        if let controlTwo = entry.configuration.controlTypeTwo {
                            WidgetControlButton(controlType: controlTwo, isActive: isActive(for: controlTwo), intent: intent(for: controlTwo))
                        }
                        
                        if let controlThree = entry.configuration.controlTypeThree {
                            WidgetControlButton(controlType: controlThree, isActive: isActive(for: controlThree), intent: intent(for: controlThree))
                        }
                        
                        if let controlFour = entry.configuration.controlTypeFour {
                            WidgetControlButton(controlType: controlFour, isActive: isActive(for: controlFour), intent: intent(for: controlFour))
                        }
                    }
                    
                    HStack {
                        if let controlFive = entry.configuration.controlTypeFive {
                            WidgetControlButton(controlType: controlFive, isActive: isActive(for: controlFive), intent: intent(for: controlFive))
                        }
                        
                        if let controlSix = entry.configuration.controlTypeSix {
                            WidgetControlButton(controlType: controlSix, isActive: isActive(for: controlSix), intent: intent(for: controlSix))
                        }
                        
                        if let controlSeven = entry.configuration.controlTypeSeven {
                            WidgetControlButton(controlType: controlSeven, isActive: isActive(for: controlSeven), intent: intent(for: controlSeven))
                        }
                        
                        if let controlEight = entry.configuration.controlTypeEight {
                            WidgetControlButton(controlType: controlEight, isActive: isActive(for: controlEight), intent: intent(for: controlEight))
                        }
                    }
                }
                .padding()
            
            default:
                EmptyView()
            }
        } else {
            Text("No Vehicle Found")
        }
    }
    
    private func isActive(for controlType: ControlType) -> Bool {
        switch controlType {
        case .wake:
            return false
        case .doorLocks:
            return entry.vehicleState?.bodyState.doorLocks == .locked
        case .frunk:
            return entry.vehicleState?.bodyState.frontCargo != .closed
        case .trunk:
            return entry.vehicleState?.bodyState.rearCargo != .closed
        case .chargePort:
            return entry.vehicleState?.bodyState.chargePortState != .closed
        case .climateControl:
            return entry.vehicleState?.hvacState.power == .hvacOn
        case .maxAC:
            return entry.vehicleState?.hvacState.maxAcStatus == .on
        case .seatClimate:
            return entry.vehicleState?.hvacState.seats.isOn ?? false
        case .steeringWheelClimate:
            return entry.vehicleState?.hvacState.steeringHeater == .on
        case .defrost:
            return entry.vehicleState?.hvacState.defrost == .defrostOn
        case .horn:
            return false
        case .lights:
            return entry.vehicleState?.chassisState.headlights == .on
        case .hazards:
            return false
        case .windows:
            return entry.vehicleState?.bodyState.windowPosition.isOpen ?? false
        case .batteryPrecondition:
            return entry.vehicleState?.batteryState.preconditioningStatus == .batteryPreconOn
        case .softwareUpdate:
            return false
        case .chargeLimit:
            return false
        case .driverSeatHeat:
            return false
        case .driverSeatVent:
            return false
        case .passengerSeatHeat:
            return false
        case .passengerSeatVent:
            return false
        case .rearLeftSeatHeat:
            return false
        case .rearCenterSeatHeat:
            return false
        case .rearRightSeatHeat:
            return false
        case .alarm:
            return false
        }
    }
    
    private func intent(for controlType: ControlType) -> any AppIntent {
        switch controlType {
        case .wake:
            return WakeIntent(vehicle: entry.configuration.$vehicle)
        case .doorLocks:
            let action = entry.vehicleState?.bodyState.doorLocks == .locked ? LockAction.unlocked : .locked
            let intent = DoorLockIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .frunk:
            let action = entry.vehicleState?.bodyState.frontCargo == .closed ? OpenAction.open : .close
            let intent = FrunkIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .trunk:
            let action = entry.vehicleState?.bodyState.rearCargo == .closed ? OpenAction.open : .close
            let intent = TrunkIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .chargePort:
            let action = entry.vehicleState?.bodyState.chargePortState == .closed ? OpenAction.open : .close
            let intent = ChargePortIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .climateControl:
            let action = entry.vehicleState?.hvacState.power == .hvacOn ? ClimateStatus.off : .on
            let intent = ClimateIntent(vehicle: entry.configuration.$vehicle)
            intent.status = action
            return intent
        case .maxAC:
            let action = entry.vehicleState?.hvacState.maxAcStatus == .on ? MaxAxStatus.off : .on
            let intent = MaxAcIntent(vehicle: entry.configuration.$vehicle)
            intent.status = action
            return intent
        case .seatClimate:
            break
        case .steeringWheelClimate:
            let action = entry.vehicleState?.hvacState.steeringHeater == .on ? SteeringWheelHeatStatus.off : .on
            let intent = SteeringWheelHeatIntent(vehicle: entry.configuration.$vehicle)
            intent.status = action
            return intent
        case .defrost:
            let action = entry.vehicleState?.hvacState.defrost == .defrostOn ? DefrostStatus.off : .on
            let intent = DefrostIntent(vehicle: entry.configuration.$vehicle)
            intent.status = action
            return intent
        case .horn:
            break
        case .lights:
            let action = entry.vehicleState?.chassisState.headlights == .on ? LightControlAction.off : .on
            let intent = LightsIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .hazards:
            break
        case .windows:
            var action: WindowAction = WindowAction.closed
            
            switch entry.vehicleState?.bodyState.windowPosition.leftFront {
            case .fullyClosed:
                action = .vent
            case .fullyOpen:
                action = .closed
            default:
                action = .vent
            }
            
            let intent = WindowIntent(vehicle: entry.configuration.$vehicle)
            intent.action = action
            return intent
        case .batteryPrecondition:
            let action = entry.vehicleState?.batteryState.preconditioningStatus == .batteryPreconOn ? PreconditionStatus.off : .on
            let intent = BatteryPreconditionIntent(vehicle: entry.configuration.$vehicle)
            intent.status = action
            return intent
        case .softwareUpdate:
            break
        case .chargeLimit:
            break
        case .driverSeatHeat:
            break
        case .driverSeatVent:
            break
        case .passengerSeatHeat:
            break
        case .passengerSeatVent:
            break
        case .rearLeftSeatHeat:
            break
        case .rearCenterSeatHeat:
            break
        case .rearRightSeatHeat:
            break
        case .alarm:
            break
        }
        
        return WakeIntent(vehicle: entry.configuration.$vehicle)
    }
}

struct Bear_Talk_Widget_Extension: Widget {
    let kind: String = "Bear_Talk_Widget_Extension"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: BearWidgetIntent.self, provider: Provider()) { entry in
            Bear_Talk_Widget_ExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Lucid Controls")
        .description("Common Controls for your Lucid")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}
