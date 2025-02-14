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


import SwiftUI
import UIKit

struct MainPage_ProfilView_ProfilPicture: View {
    @StateObject private var viewModel = MainPageProfilPictureViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    if viewModel.isLoading {
                        ProgressView("Lade Profilbild...")
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        profileImageView
                        deleteButton
                        imageSelectionButtons
                    }
                }
                .padding()
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePicker(
                    selectedImage: $viewModel.selectedImage,
                    sourceType: viewModel.sourceType,
                    onImagePicked: { viewModel.updateProfileImage(with: $0) }
                )
            }
        }
    }

    // MARK: - Profilbild-Anzeige
    private var profileImageView: some View {
        ZStack {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Text(viewModel.shortName)
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
        }
    }

    // MARK: - Löschen-Button
    private var deleteButton: some View {
        Button("Löschen") {
            viewModel.deleteProfileImage()
        }
        .font(.headline)
        .foregroundColor(.red)
        .disabled(viewModel.isUpdating)
    }

    // MARK: - Kamera- und Galerie-Auswahl
    private var imageSelectionButtons: some View {
        HStack(spacing: 50) {
            imageButton(icon: "camera.fill", label: "Kamera", color: .blue) {
                viewModel.sourceType = .camera
                viewModel.showImagePicker = true
            }
            
            imageButton(icon: "photo.fill.on.rectangle.fill", label: "Galerie", color: .green) {
                viewModel.sourceType = .photoLibrary
                viewModel.showImagePicker = true
            }
        }
    }

    // MARK: - Generischer Button für Kamera/Galerie
    private func imageButton(icon: String, label: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(color)
                Text(label)
                    .font(.headline)
                    .foregroundColor(color)
            }
            .padding()
            .background(Color(UIColor.systemGray6))
            .cornerRadius(15)
        }
    }
}
