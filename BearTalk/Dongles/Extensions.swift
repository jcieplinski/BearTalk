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
