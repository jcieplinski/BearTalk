//
//  CarSceneModel.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 5/20/25.
//

import Foundation

enum CarSceneModel: String, CaseIterable {
    case air = "Air"
    case gravity = "Gravity"
    case sapphire = "Sapphire"
    
    var displayTitle: String {
        switch self {
        case .air: return "Air"
        case .gravity: return "Gravity"
        case .sapphire: return "Sapphire"
        }
    }

    init(model: LucidModel, variant: ModelVariant) {
        switch model {
        case .gravity:
            self = .gravity
        case .air where variant == .sapphire:
            self = .sapphire
        default:
            self = .air
        }
    }

    static var storedOverride: CarSceneModel? {
        let raw = UserDefaults.appGroup.string(forKey: DefaultsKey.carModelOverride) ?? ""
        guard !raw.isEmpty else { return nil }
        return CarSceneModel(rawValue: raw)
    }
}

enum AppearanceOverrides {
    static func migrateLegacy(into actual: CarSceneModel) {
        guard actual != .sapphire else { return }
        for base in [
            DefaultsKey.carColorOverride,
            DefaultsKey.customPaintColor,
            DefaultsKey.interiorOverride,
            DefaultsKey.lookOverride,
            DefaultsKey.wheelsOverride
        ] {
            let scoped = DefaultsKey.scoped(base, model: actual)
            let defaults = UserDefaults.appGroup
            guard defaults.object(forKey: scoped) == nil,
                  let legacy = defaults.string(forKey: base),
                  !legacy.isEmpty else { continue }
            defaults.set(legacy, forKey: scoped)
        }
    }
}
