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
                 AppShortcut(intent: CurrentElevationIntent(),
                             phrases: ["Elevation with \(.applicationName)"],
                             shortTitle: "Elevation",
                             systemImageName: "location.north.circle.fill"),
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
                 AppShortcut(intent: CurrentRangeIntent(),
                             phrases: ["What's my Range in \(.applicationName)?"],
                             shortTitle: "Range",
                             systemImageName: "ruler.fill"),
                 AppShortcut(intent: SeatClimateIntent(),
                             phrases: ["\(.applicationName) seats"],
                             shortTitle: "Seat Climate",
                             systemImageName: "sun.min"
                            )
        ]
    }
}
