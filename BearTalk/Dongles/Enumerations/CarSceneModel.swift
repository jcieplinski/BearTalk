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
}
