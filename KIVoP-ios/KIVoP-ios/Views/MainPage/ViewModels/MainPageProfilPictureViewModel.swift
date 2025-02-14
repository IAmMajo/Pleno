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
//  MainPageProfilPictureViewModel.swift
//  KIVoP-ios
//
//  Created by Amine Ahamri on 11.02.25.
//


// This file is licensed under the MIT-0 License.

import SwiftUI
import UIKit

class MainPageProfilPictureViewModel: ObservableObject {
    @Published var showImagePicker = false
    @Published var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Published var selectedImage: UIImage? = nil
    @Published var shortName: String = ""
    @Published var errorMessage: String? = nil
    @Published var isLoading: Bool = true
    @Published var isUpdating: Bool = false

    init() {
        fetchProfileImage()
    }

    // MARK: - Profilbild abrufen
    func fetchProfileImage() {
        isLoading = true
        errorMessage = nil

        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let profile):
                    if let imageData = profile.profileImage, let image = UIImage(data: imageData) {
                        self.selectedImage = image
                    } else {
                        self.selectedImage = nil
                    }
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name)
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden des Profilbilds: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Profilbild aktualisieren
    func updateProfileImage(with updatedImage: UIImage?) {
        isUpdating = true
        errorMessage = nil

        MainPageAPI.updateUserProfileImage(profileImage: updatedImage) { result in
            DispatchQueue.main.async {
                self.isUpdating = false
                switch result {
                case .success:
                    print("Profilbild erfolgreich aktualisiert.")
                    self.selectedImage = updatedImage
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.code == 423 {
                        self.errorMessage = nsError.localizedDescription
                    } else {
                        self.errorMessage = "Fehler beim Aktualisieren des Profilbilds: \(error.localizedDescription)"
                    }
                }
            }
        }
    }

    // MARK: - Profilbild löschen
    func deleteProfileImage() {
        selectedImage = nil
        shortName = MainPageAPI.calculateShortName(from: "")

        isUpdating = true
        errorMessage = nil

        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name)
                case .failure(let error):
                    self.shortName = MainPageAPI.calculateShortName(from: "Anonym")
                    debugPrint("❌ Fehler beim Laden des Benutzernamens: \(error.localizedDescription)")
                }
            }
        }

        MainPageAPI.updateUserProfileImage(profileImage: UIImage()) { result in
            DispatchQueue.main.async {
                self.isUpdating = false
                switch result {
                case .success:
                    print("Profilbild erfolgreich gelöscht.")
                case .failure(let error):
                    if let nsError = error as NSError?, nsError.code == 423 {
                        self.errorMessage = nsError.localizedDescription
                    } else {
                        self.errorMessage = "Fehler beim Löschen des Profilbilds: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
