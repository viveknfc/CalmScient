//
//  SessionKeychainStore.swift
//  Calmscient
//
//  Created by NFC Solutions on 19/08/26.
//

import Foundation
import Security

/// Keychain storage for the persisted session blob (login details + tokens).
///
/// Why this exists: that blob holds a refresh token and the patient's identifiers, and it is
/// now read by background health sync while the phone sits locked in a pocket. `UserDefaults`
/// did work for that — an app container is protected only "until first unlock" — but a plist
/// in the app's Library directory is the wrong home for a credential that unlocks a patient's
/// clinical record.
///
/// `kSecAttrAccessibleAfterFirstUnlock` is a deliberate choice over `...WhenUnlocked`: the
/// latter would make these items unreadable during exactly the background wake-ups that
/// health sync depends on.
///
/// This type is storage only. *Whether* a session may be persisted at all is still decided by
/// `UserDefaultsHelper.persistLoginDetailsIfRemembered`.
enum SessionKeychainStore {

    private static let service = "com.calmscient.session"

    static func save(_ data: Data, for account: String) {
        // A bare `SecItemAdd` fails with errSecDuplicateItem on the second login, so
        // delete-then-add keeps the write idempotent.
        delete(account)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("SessionKeychainStore: save failed for \(account), OSStatus \(status)")
        }
    }

    static func read(_ account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            // errSecItemNotFound is the ordinary "no session stored" case, not a problem.
            if status != errSecItemNotFound {
                print("SessionKeychainStore: read failed for \(account), OSStatus \(status)")
            }
            return nil
        }
        return item as? Data
    }

    static func delete(_ account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("SessionKeychainStore: delete failed for \(account), OSStatus \(status)")
        }
    }
}
