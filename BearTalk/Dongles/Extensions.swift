//
//  Extensions.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation
import SceneKit
import SwiftUI

extension String {
    var trimmed: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var withNonBreakingSpaces: String {
        let characters = map { element -> Character in
            return element.isWhitespace ? "\u{00a0}" : element
        }

        return String(characters)
    }

    var withFinalNonBreakingSpace: String {
        if let range = range(of: " ", options: NSString.CompareOptions.backwards) {
            return replacingCharacters(in: range, with: "\u{00a0}")
        }

        return self
    }

    var isBlank: Bool {
        return trimmed.isEmpty
    }

    var isNotBlank: Bool {
        return !isBlank
    }
}

extension Double {

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }

    func stringWithLocale() -> String {
        return NSNumber(value: self.round(to: 2)).description(withLocale: Locale.autoupdatingCurrent)
    }
}

extension SCNScene {
    /// Paints the body. Stellar White keeps the same color and uses less metalness.
    func applyCarPaint(_ paint: PaintColor) {
        let uiColor = UIColor(paint.color)
        rootNode.enumerateChildNodes { node, _ in
            guard let materials = node.geometry?.materials else { return }
            for material in materials {
                let name = material.name?.lowercased() ?? ""
                guard name.contains("carpaint") || name.contains("car_paint") else { continue }
                material.diffuse.contents = uiColor
                material.applyStellarWhiteMetalness(paint == .stellarWhite)
            }
        }
    }

    /// Tints Air rear seats and carpets. Front seats stay Mojave.
    func tintAirInterior(_ color: Color) {
        let uiColor = UIColor(color)
        let recoloredLeather: Set<String> = [
            "LUCID_LP_leather_C",
            "LUCID_LP_leather_C_perf",
            "Door_01_FL_leather_C",
            "Door_02_FR_leather_C",
            "Door_03_RL_leather_C",
            "Door_04_RR_leather_C"
        ]
        rootNode.enumerateChildNodes { node, _ in
            guard let geometry = node.geometry else { return }
            if let name = node.name, recoloredLeather.contains(name) {
                geometry.materials = geometry.materials.map { material in
                    let copy = (material.copy() as? SCNMaterial) ?? material
                    if copy.name == "leather_C" || copy.name == "leather_C_perf" {
                        copy.diffuse.contents = uiColor
                    }
                    return copy
                }
                return
            }
            for material in geometry.materials where material.name == "carpet_B" || material.name == "carpet_dark" {
                material.diffuse.contents = uiColor
            }
        }
    }

    /// Tints Gravity seat leather. Other door leather stays Mojave grey.
    /// The center armrest shares leather_black, so it gets its own copy.
    func tintLeather(_ color: Color) {
        let seatColor = UIColor(color)
        let blackLeather = UIColor(Interior.mojave.leatherColor)
        rootNode.enumerateChildNodes { node, _ in
            guard let geometry = node.geometry, !geometry.materials.isEmpty else { return }
            if node.name == "Main_Mesh_Yosemite" {
                geometry.materials = geometry.materials.map { material in
                    let copy = (material.copy() as? SCNMaterial) ?? material
                    if copy.name == "leather_black" {
                        // This pad faces the key light, so the seat color reads lighter here.
                        copy.diffuse.contents = seatColor.scaled(by: 0.6)
                        copy.roughness.contents = 0.7
                    }
                    return copy
                }
                return
            }
            for material in geometry.materials {
                switch material.name {
                case "leather_black":
                    material.diffuse.contents = blackLeather
                case "configuration_int_leather_seats":
                    material.multiply.contents = seatColor
                case "configuration_int_middle_beltline":
                    material.diffuse.contents = seatColor
                default:
                    break
                }
            }
        }
    }
}

private extension UIColor {
    func scaled(by factor: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 1
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return UIColor(red: red * factor, green: green * factor, blue: blue * factor, alpha: alpha)
        }
        guard let converted = cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil),
              let components = converted.components,
              components.count >= 3 else {
            return self
        }
        return UIColor(red: components[0] * factor, green: components[1] * factor, blue: components[2] * factor, alpha: alpha)
    }
}

private enum CarPaintMetalness {
    static var defaults: [ObjectIdentifier: (contents: NSNumber, intensity: CGFloat)] = [:]
}

private extension SCNMaterial {
    func applyStellarWhiteMetalness(_ enabled: Bool) {
        let id = ObjectIdentifier(self)
        if CarPaintMetalness.defaults[id] == nil, let number = metalness.contents as? NSNumber {
            CarPaintMetalness.defaults[id] = (number, metalness.intensity)
        }
        guard let saved = CarPaintMetalness.defaults[id] else { return }
        metalness.contents = saved.contents
        metalness.intensity = enabled ? saved.intensity * 0.65 : saved.intensity
    }
}
