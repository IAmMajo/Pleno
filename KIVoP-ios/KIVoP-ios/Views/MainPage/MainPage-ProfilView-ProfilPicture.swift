import SwiftUI
import UIKit

struct MainPage_ProfilView_ProfilPicture: View {
    @State private var showImagePicker = false
    @State private var ShortName: String = "MM"
    @State private var sourceType: UIImagePickerController.SourceType = .camera // Default to camera for direct opening
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Profile Picture Display
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
                                Text(ShortName)
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                }

                // Delete Button
                Button(action: {
                    self.selectedImage = nil // Aktion aktuelles Bild löschen
                }) {
                    Text("Löschen")
                        .font(.headline)
                        .foregroundColor(.red)
                }

                // Aktion Buttons
                HStack(spacing: 50) {
                    Button(action: {
                        self.sourceType = .camera
                        self.showImagePicker = true
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
                        self.sourceType = .photoLibrary
                        self.showImagePicker = true
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: self.$selectedImage, sourceType: self.sourceType)
        }
    }
}

struct MainPage_ProfilView_ProfilPicture_Previews: PreviewProvider {
    static var previews: some View {
        MainPage_ProfilView_ProfilPicture()
    }
}

// ImagePicker View
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

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}
