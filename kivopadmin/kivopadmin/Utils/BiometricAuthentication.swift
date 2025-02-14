// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

//
//  BiometricAuthentication.swift
//  kivopadmin
//
//  Created by Amine Ahamri on 26.11.24.
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
    
    /// Führt einen Abschluss aus, wenn die Authentifizierung erfolgreich ist
    static public func executeIfSuccessfulAuth(
        _ onSuccessClosure: () -> Void,
        otherwise onFailedClosure: (() -> Void)? = nil
    ) async {
        guard await authenticate() else {
            if let onFailedClosure {
                onFailedClosure()
            }
            return
        }
        onSuccessClosure()
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
