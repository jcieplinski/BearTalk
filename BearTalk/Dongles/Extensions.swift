//
//  Extensions.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 11/28/23.
//

import Foundation

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
