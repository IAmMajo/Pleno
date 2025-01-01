//
//  KeychainHelper.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 26.11.24.
//

import Security
import Foundation

import Security
import Foundation

class KeychainHelper {
    /// Speichert einen neuen Eintrag oder aktualisiert den vorhandenen Eintrag für den angegebenen Schlüssel.
    static func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else {
            print("[DEBUG] Fehler: Wert konnte nicht in Data konvertiert werden.")
            return
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        if status == errSecSuccess {
            // Vorhandenen Eintrag aktualisieren
            let attributesToUpdate: [String: Any] = [kSecValueData as String: data]
            let updateStatus = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            if updateStatus == errSecSuccess {
                print("[DEBUG] Eintrag für \(key) erfolgreich aktualisiert.")
            } else {
                print("[DEBUG] Fehler beim Aktualisieren des Eintrags für \(key): \(updateStatus)")
            }
        } else if status == errSecItemNotFound {
            // Neuen Eintrag hinzufügen
            var newQuery = query
            newQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(newQuery as CFDictionary, nil)
            if addStatus == errSecSuccess {
                print("[DEBUG] Neuer Eintrag für \(key) erfolgreich gespeichert.")
            } else {
                print("[DEBUG] Fehler beim Speichern des Eintrags für \(key): \(addStatus)")
            }
        } else {
            print("[DEBUG] Fehler beim Suchen des Eintrags für \(key): \(status)")
        }
    }

    /// Lädt den Wert für einen angegebenen Schlüssel.
    static func load(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var data: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &data)
        if status == errSecSuccess, let data = data as? Data {
            return String(data: data, encoding: .utf8)
        }
        print("[DEBUG] Fehler beim Laden des Werts für \(key): \(status)")
        return nil
    }

    /// Löscht den Eintrag für einen angegebenen Schlüssel.
    static func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        if status == errSecSuccess {
            print("[DEBUG] Eintrag für \(key) erfolgreich gelöscht.")
        } else {
            print("[DEBUG] Fehler beim Löschen des Eintrags für \(key): \(status)")
        }
    }
}
