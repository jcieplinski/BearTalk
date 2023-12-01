//
//  Keychain.swift
//  BearTalk
//
//  Created by Joe Cieplinski on 12/1/23.
//

import Security
import UIKit

final class KeyChain {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound

        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem

        // A read of an item in any format other than Data
        case invalidItemFormat

        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }

    static func save(password: Data, service: String, account: String) throws {

        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: password as AnyObject
        ]

        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func update(password: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to update in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        let attributes: [String: AnyObject] = [
            kSecValueData as String: password as AnyObject
        ]

        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    static func readPassword(service: String, account: String) throws -> Data {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue
        ]

        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        guard let password = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }

        return password
    }

    static func deletePassword(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
