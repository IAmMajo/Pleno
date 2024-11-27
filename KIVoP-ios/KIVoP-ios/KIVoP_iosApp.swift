//
//  KIVoP_iosApp.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 29.10.24.
//

import SwiftUI

@main
struct KIVoP_iosApp: App {
    var body: some Scene {
        WindowGroup {
            Onboarding()
                .environmentObject(AuthController.shared)
        }
    }
}
