//
//  BearAutoShortcuts.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/8/23.
//

import AppIntents

struct BearAutoShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return  [
                 AppShortcut(intent: DoorLockIntent(),
                             phrases: ["\(.applicationName) Door Locks"],
                             shortTitle: "Bear Unlock",
                             systemImageName: "lock.open.fill"),
                 AppShortcut(intent: FrunkIntent(),
                             phrases: ["\(.applicationName) Frunk"],
                             shortTitle: "Open or Close Frunk",
                             systemImageName: "car.side.front.open.fill"),
                 AppShortcut(intent: TrunkIntent(),
                             phrases: ["\(.applicationName) Trunk"],
                             shortTitle: "Open or Close Trunk",
                             systemImageName: "car.side.back.open.fill"),
                 AppShortcut(intent: WakeIntent(),
                             phrases: ["Wake Car with \(.applicationName)"],
                             shortTitle: "Wake Car",
                             systemImageName: "sunrise.fill"),
                 AppShortcut(intent: RideHeightIntent(),
                             phrases: ["\(.applicationName) Ride Height"],
                             shortTitle: "Ride Height",
                             systemImageName: "arrow.up.and.down"),
                 AppShortcut(intent: KeylessDrivingIntent(),
                             phrases: ["\(.applicationName) Keyless Driving"],
                             shortTitle: "Keyless Driving",
                             systemImageName: "key.fill"),
                 AppShortcut(intent: HornIntent(),
                             phrases: ["\(.applicationName) Honk Horn"],
                             shortTitle: "Honk Horn",
                             systemImageName: "horn.fill"),
                 AppShortcut(intent: HazardsIntent(),
                             phrases: ["\(.applicationName) Hazard Lights"],
                             shortTitle: "Hazard Lights",
                             systemImageName: "light.beacon.max"),
                 AppShortcut(intent: KeepClimateIntent(),
                             phrases: ["\(.applicationName) Keep Climate"],
                             shortTitle: "Keep Climate",
                             systemImageName: "thermometer.medium"),
                 AppShortcut(intent: CreatureComfortIntent(),
                             phrases: ["\(.applicationName) Creature Comfort"],
                             shortTitle: "Creature Comfort",
                             systemImageName: "pawprint.fill")
        ]
    }
}
