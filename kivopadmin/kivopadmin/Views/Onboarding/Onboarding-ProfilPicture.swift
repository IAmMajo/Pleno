// This file is licensed under the MIT-0 License.
import SwiftUI
import UIKit

struct Onboarding_ProfilePicture: View {
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var imagePickerType: ImagePickerType? // Optional, um das Sheet korrekt zu kontrollieren

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    // Profilbild oder Platzhalter
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
                        }
                    }

                    // Kamera- und Galerie-Aktionen
                    HStack(spacing: 50) {
                        Button(action: {
                            imagePickerType = ImagePickerType(type: .camera)
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
                            imagePickerType = ImagePickerType(type: .photoLibrary)
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
                .padding()
            }
            .sheet(item: $imagePickerType) { pickerType in
                ImagePicker(selectedImage: $selectedImage, sourceType: pickerType.type)
            }
        }
    }

    // MARK: - Wrapper für SourceType
    struct ImagePickerType: Identifiable {
        let id = UUID()
        let type: UIImagePickerController.SourceType
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

            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
