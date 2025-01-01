//
//  BiometricAuthentication.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.11.24.
//

import Foundation
import LocalAuthentication

public class BiometricAuth {
    
    /// Asynchrone Authentifizierung mit Face ID oder Touch ID
    static public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Prüfen, ob Authentifizierung möglich ist
        if context.canEvaluatePolicy(
            .deviceOwnerAuthentication, error: &error
        ) {
            do {
                // Authentifizierung ausführen und Ergebnis zurückgeben
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Bitte bestätigen Sie sich mit Face ID oder Touch ID."
                )
            } catch {
                print("Fehler bei der biometrischen Authentifizierung: \(error.localizedDescription)")
                return false
            }
        } else {
            print("Biometrische Authentifizierung nicht verfügbar: \(error?.localizedDescription ?? "Unbekannter Fehler")")
            return false
        }
    }
   
   static public func executeIfSuccessfulAuth(
     _ onSuccessClosure: @escaping () async -> Void,
     otherwise onFailedClosure: (() -> Void)? = nil
   ) async {
     guard await authenticate() else {
         if let onFailedClosure {
             onFailedClosure()
         }
         return
     }
     await onSuccessClosure()
   }

    /// Prüft, ob biometrische Authentifizierung verfügbar ist
    static public func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    /// Authentifiziert den Benutzer mit Face ID/Touch ID und führt eine Aktion aus
    static public func authenticateWithBiometrics(
        localizedReason: String = "Bitte bestätigen Sie sich mit Face ID oder Touch ID.",
        completion: @escaping (Bool, Error?) -> Void
    ) {
        let context = LAContext()
        var error: NSError?

        // Prüfen, ob Face ID/Touch ID verfügbar ist
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason) { success, authError in
                DispatchQueue.main.async {
                    completion(success, authError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, error)
            }
        }
    }
}
