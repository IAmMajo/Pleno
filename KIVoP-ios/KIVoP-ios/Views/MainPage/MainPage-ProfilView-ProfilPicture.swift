import SwiftUI
import UIKit

struct MainPage_ProfilView_ProfilPicture: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage? = nil
    @State private var shortName: String = "NN"
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = true
    @State private var isUpdating: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    // Ladeanzeige oder Fehlermeldung
                    if isLoading {
                        ProgressView("Lade Profilbild...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        ZStack {
                            // Profilbild oder Platzhalter anzeigen
                            if let image = selectedImage {
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
                                        Text(shortName)
                                            .font(.system(size: 60, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                        }

                        // Button zum Löschen des Profilbilds
                        Button("Löschen") {
                            deleteProfileImage()
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .disabled(isUpdating)

                        // Auswahl zwischen Kamera und Galerie
                        HStack(spacing: 50) {
                            Button(action: {
                                sourceType = .camera
                                showImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "camera.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.blue)
                                    Text("Kamera")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(15)
                            }

                            Button(action: {
                                sourceType = .photoLibrary
                                showImagePicker = true
                            }) {
                                VStack {
                                    Image(systemName: "photo.fill.on.rectangle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.green)
                                    Text("Galerie")
                                        .font(.headline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(15)
                            }
                        }
                    }
                }
                .padding()
                .onAppear {
                    fetchProfileImage()
                }
            }
            // Bildauswahl-Sheet
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType) { updatedImage in
                    self.updateProfileImage(with: updatedImage)
                }
            }
        }
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
                        errorMessage = nsError.localizedDescription
                    } else {
                        errorMessage = "Fehler beim Aktualisieren des Profilbilds: \(error.localizedDescription)"
                    }

                }
            }
        }
    }

    // MARK: - Profilbild löschen
    func deleteProfileImage() {
        // Profilbild lokal entfernen
        selectedImage = nil
        shortName = MainPageAPI.calculateShortName(from: "") // Vorläufiger Fallback-Name

        // Indikator setzen
        isUpdating = true
        errorMessage = nil

        // Nutzername erneut abrufen, um ein Fallback-Kürzel anzuzeigen
        MainPageAPI.fetchUserProfile { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profile):
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name)
                case .failure(let error):
                    debugPrint("❌ Fehler beim Laden des Benutzernamens: \(error.localizedDescription)")
                    self.shortName = MainPageAPI.calculateShortName(from: "Anonym")
                }
            }
        }

        // API-Aufruf zum Löschen des Profilbilds
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



    // MARK: - ImagePicker für Kamera- und Galerie-Funktionalität
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var sourceType: UIImagePickerController.SourceType
        var onImagePicked: (UIImage?) -> Void

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            picker.allowsEditing = true
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
            uiViewController.sourceType = sourceType
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    parent.onImagePicked(image)
                }
                picker.dismiss(animated: true)
            }

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
