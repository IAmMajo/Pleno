import SwiftUI
import UIKit

struct MainPage_ProfilView_ProfilPicture: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage? = nil
    @State private var shortName: String = "NN" // Standard-Shortname
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    if isLoading {
                        ProgressView("Lade Profilbild...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        // Profilbild oder ShortName anzeigen
                        ZStack {
                            if let image = selectedImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 200, height: 200)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.primary, lineWidth: 3))
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
                        
                        // Löschen-Button
                        Button("Löschen") {
                            deleteProfileImage()
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .disabled(selectedImage == nil) // Deaktivieren, falls kein Bild vorhanden
                        
                        // Kamera- und Galerie-Aktionen
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
        }
    }

    // MARK: - Profilbild vom Server abrufen
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
                    // Dynamischen ShortName basierend auf dem Namen setzen
                    self.shortName = MainPageAPI.calculateShortName(from: profile.name ?? "")
                case .failure(let error):
                    self.errorMessage = "Fehler beim Laden des Profilbilds: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Profilbild löschen (Dummy)
    func deleteProfileImage() {
        self.selectedImage = nil
        print("Profilbild gelöscht.")
    }

    // MARK: - ImagePicker
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var sourceType: UIImagePickerController.SourceType
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            picker.allowsEditing = true
            return picker
        }
        
        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
        
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
                    parent.selectedImage = image
                }
                picker.dismiss(animated: true)
            }
        }
    }
}
