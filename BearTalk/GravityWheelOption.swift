import Foundation

enum GravityWheelOption: String, CaseIterable, Identifiable {
    case aether
    case orion
    case voyager
    
    var nodeTitle: String {
        switch self {
        case .voyager: return "Wheel_Set3_Voyager"
        case .orion: return "Wheel_Set2_Orion"
        case .aether: return "Wheel_Set1_Aether"
        }
    }
    
    var displayTitle: String {
        switch self {
        case .aether: return "22\" / 23\" Aether"
        case .orion: return "21\" / 22\" Orion"
        case .voyager: return "20\" / 21\" Voyager"
        }
    }
    
    var id: String { rawValue }
} 
