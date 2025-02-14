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
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.11.24.
//

import Foundation
import LocalAuthentication

/// A utility class that manages biometric authentication (Face ID & Touch ID)
public class BiometricAuth {
    
   // MARK: - Biometric Authentication
   /// Performs asynchronous biometric authentication using Face ID or Touch ID
   static public func authenticate() async -> Bool {
      let context = LAContext()
      var error: NSError?
      
      // Check if biometric authentication is available
      if context.canEvaluatePolicy(
         .deviceOwnerAuthentication, error: &error
      ) {
         do {
            // Perform authentication and return the result
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
   
   // MARK: - Execute with Authentication
   /// Executes a closure if authentication is successful; otherwise, executes a failure closure if provided
   static public func executeIfSuccessfulAuth(
      _ onSuccessClosure: @escaping () async -> Void,
      otherwise onFailedClosure: (() -> Void)? = nil
   ) async {
      guard await authenticate() else {
         // Executes the failure closure if authentication fails
         if let onFailedClosure {
            onFailedClosure()
         }
         return
      }
      // Executes the success closure if authentication is successful
      await onSuccessClosure()
   }
   
   // MARK: - Availability Check
   /// Checks if biometric authentication (Face ID/Touch ID) is available on the device
   static public func isBiometricAvailable() -> Bool {
      let context = LAContext()
      var error: NSError?
      return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
   }
   
   // MARK: - Authenticate with Completion Handler
   /// Authenticates the user using Face ID or Touch ID and executes a completion handler
   static public func authenticateWithBiometrics(
      localizedReason: String = "Bitte bestätigen Sie sich mit Face ID oder Touch ID.",
      completion: @escaping (Bool, Error?) -> Void
   ) {
      let context = LAContext()
      var error: NSError?
      
      // Check if biometric authentication is available
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
