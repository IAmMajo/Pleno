//
//  BiometricAuthentication.swift
//  KIVoP-ios
//
//  Created by Hanna Steffen on 16.11.24.
//

import Foundation
import LocalAuthentication

public class BiometricAuth {
    static public func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?

        // Check whether authentication is possible
        if context.canEvaluatePolicy(
          .deviceOwnerAuthentication, error: &error
        ) {
            do {
                // Return the result of the authentication
                return try await context
                  .evaluatePolicy(
                    .deviceOwnerAuthentication,
                    localizedReason: "Authentication Required."
                  )
            } catch {
               print("Unhandled biometric auth err: \(error.localizedDescription)")
                return false
            }
        } else {
            // No Password or Biometrics to auth -> return true
            return true
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

}
