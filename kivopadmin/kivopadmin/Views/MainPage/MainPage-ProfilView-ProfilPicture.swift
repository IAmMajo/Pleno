import SwiftUI
import UIKit

struct MainPage_ProfilView_ProfilPicture: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera // Standardmäßig Kamera
    @State private var selectedImage: UIImage? = nil
    @State private var shortName: String = "MM"
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
                        // Profilbild-Anzeige
                        ZStack {
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

                        // Löschen-Button
                        Button(action: {
                            deleteProfilePicture()
                        }) {
                            Text("Löschen")
                                .font(.headline)
                                .foregroundColor(.red)
                        }

                        // Aktionen
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
                    loadProfilePicture()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
            }
        }
    }

    // MARK: - API-Aufrufe über MainPageAPI

    private func loadProfilePicture() {
        isLoading = true
        errorMessage = nil

        MainPageAPI.fetchProfilePicture { result in
            DispatchQueue.main.async {
                self.isLoading = false

                switch result {
                case .success(let image):
                    self.selectedImage = image
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func uploadProfilePicture(image: UIImage) {
        MainPageAPI.uploadProfilePicture(image: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func deleteProfilePicture() {
        MainPageAPI.deleteProfilePicture { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.selectedImage = nil
                    self.errorMessage = nil
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
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

struct MainPage_ProfilView_ProfilPicture_Previews: PreviewProvider {
    static var previews: some View {
        MainPage_ProfilView_ProfilPicture()
    }
}
