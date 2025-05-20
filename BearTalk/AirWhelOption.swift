//
//  AirWhelOptions.swift
//  SceneTest
//
//  Created by Joe Cieplinski on 5/19/25.
//

import Foundation

enum AirWheelOption: String, CaseIterable, Identifiable {
  case aero19
  case aeroLite20
  case aeroBlade21
  case aeroSport21
  case dream21
  
  var nodeTitle: String {
    switch self {
    case .aero19: "Wheel_Aero19"
    case .aeroBlade21: "Wheel_AeroBlade21"
    case .aeroLite20: "Wheel_AeroLite20"
    case .aeroSport21: "Wheel_AeroSport21"
    case .dream21: "Wheel_Dream21"
    }
  }
  
  var displayTitle: String {
    switch self {
    case .aero19: "19\" Aero Range"
    case .aeroBlade21: "21\" Aero Blade"
    case .aeroLite20: "20\" Aero Lite"
    case .aeroSport21: "21\" Aero Sport"
    case .dream21: "21\" Dream Edition"
    }
  }
  
  var id: String { rawValue }
}
