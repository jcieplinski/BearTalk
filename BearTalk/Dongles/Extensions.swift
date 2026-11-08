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

    /// Tints Gravity seat leather. Door leather stays Mojave grey.
    func tintLeather(_ color: Color) {
        let seatColor = UIColor(color)
        let blackLeather = UIColor(Interior.mojave.leatherColor)
        rootNode.enumerateChildNodes { node, _ in
            guard let materials = node.geometry?.materials else { return }
            for material in materials {
                switch material.name {
                case "leather_black":
                    material.diffuse.contents = blackLeather
                case "configuration_int_leather_seats":
                    material.multiply.contents = seatColor
                default:
                    break
                }
            }
        }
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
