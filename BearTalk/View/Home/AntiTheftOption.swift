import Foundation

enum AntiTheftOption: String, CaseIterable, Identifiable {
    case off
    case notificationOnly
    case notificationAndSound

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off:
            "Off"
        case .notificationOnly:
            "Mobile Notification Only"
        case .notificationAndSound:
            "Mobile Notification and Sound"
        }
    }

    var alarmMode: AlarmMode {
        switch self {
        case .off:
            .off
        case .notificationOnly:
            .silent
        case .notificationAndSound:
            .on
        }
    }

    init?(alarmMode: AlarmMode) {
        switch alarmMode {
        case .off:
            self = .off
        case .silent:
            self = .notificationOnly
        case .on:
            self = .notificationAndSound
        case .unknown, .UNRECOGNIZED:
            return nil
        }
    }
}
