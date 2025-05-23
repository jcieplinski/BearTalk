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
                             phrases: ["Unlock with \(.applicationName)"],
                             shortTitle: "Bear Unlock",
                             systemImageName: "lock.open.fill"),
                 AppShortcut(intent: LockIntent(),
                             phrases: ["Lock with \(.applicationName)"],
                             shortTitle: "Bear Lock",
                             systemImageName: "lock.fill"),
                 AppShortcut(intent: CurrentElevationIntent(),
                             phrases: ["Elevation with \(.applicationName)"],
                             shortTitle: "Elevation",
                             systemImageName: "location.north.circle.fill"),
                 AppShortcut(intent: ToggleFrunkIntent(),
                             phrases: ["Toggle Frunk with \(.applicationName)"],
                             shortTitle: "Toggle Frunk",
                             systemImageName: "car.side.front.open.fill"),
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
