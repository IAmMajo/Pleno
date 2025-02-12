//
//  MainPageProfilNameViewModel.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 11.02.25.
//


// This file is licensed under the MIT-0 License.

import SwiftUI
import AuthServiceDTOs

class MainPageProfilNameViewModel: ObservableObject {
    // Name des Benutzers
    @Published var name: String = ""
    
    // UI-Zustände
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var shouldDismiss: Bool = false

    init() {
        loadUserName()
    }

    // Holt den aktuellen Namen des Benutzers
    func loadUserName() {
        isLoading = true
        errorMessage = nil

        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    self.name = profile.name
                case .failure(let error):
                    self.errorMessage = "Fehler: \(error.localizedDescription)"
                }
            }
        }
    }

    // Aktualisiert den Namen des Benutzers
    func updateUserName() {
        guard !name.isEmpty else {
            errorMessage = "Name darf nicht leer sein."
            return
        }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        MainPageAPI.updateUserName(name: name) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success:
                    self.successMessage = "Name erfolgreich aktualisiert."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        self.shouldDismiss = true
                    }
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.code == 423 {
                        self.errorMessage = nsError.localizedDescription
                    } else {
                        self.errorMessage = "Ein Fehler ist aufgetreten: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
