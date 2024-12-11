import SwiftUI
import UIKit

struct Onboarding_ProfilePicture: View {
    @Binding var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera

    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 180, height: 180)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 180)
                        .overlay(Text("Profilbild").foregroundColor(.white))
                }
            }
            
            if selectedImage != nil {
                Button("Löschen") {
                    selectedImage = nil
                }
                .foregroundColor(.red)
            }
            
            HStack {
                Button(action: {
                    sourceType = .camera
                    showImagePicker = true
                }) {
                    Text("Kamera")
                }
                Button(action: {
                    sourceType = .photoLibrary
                    showImagePicker = true
                }) {
                    Text("Galerie")
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            OnboardingImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
    }
}

struct OnboardingImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: OnboardingImagePicker

        init(_ parent: OnboardingImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
}
