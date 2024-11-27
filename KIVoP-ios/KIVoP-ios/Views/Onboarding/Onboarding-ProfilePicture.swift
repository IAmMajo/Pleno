import SwiftUI
import UIKit

struct Onboarding_ProfilePicture: View {
    @State private var showImagePicker = false
    @State private var sourceType: UIImagePickerController.SourceType = .camera
    @State private var selectedImage: UIImage? = nil
    @State private var userName: String = "" // Dynamischer Name aus Onboarding_Register

    var shortName: String {
        if userName.isEmpty {
            return "Profilbild"
        } else {
            let nameParts = userName.split(separator: " ")
            if let firstInitial = nameParts.first?.prefix(1), let lastInitial = nameParts.last?.prefix(1) {
                return "\(firstInitial)\(lastInitial)".uppercased()
            }
            return userName
        }
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                // Profile Picture Display
                ZStack {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 180, height: 180) // Kleinere Größe für das Profilbild
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 180, height: 180) // Kleinere Größe für den Kreis
                            .overlay(
                                Text(shortName)
                                    .font(.system(size: 40, weight: .bold)) // Kleinere Schriftgröße
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            )
                    }
                }

                // Delete Button
                if selectedImage != nil {
                    Button(action: {
                        self.selectedImage = nil // Aktuelles Bild löschen
                    }) {
                        Text("Löschen")
                            .font(.headline)
                            .foregroundColor(.red)
                    }
                }

                // Action Buttons
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
            OnboardingImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onAppear {
            // Dynamischer Wert aus Onboarding_Register übernehmen
            fetchUserName()
        }
    }

    // MARK: - Helper Methods
    private func fetchUserName() {
        // Beispiel: Wenn der Name vom Server oder einer anderen View stammt
        if let storedName = UserDefaults.standard.string(forKey: "OnboardingUserName") {
            self.userName = storedName
        } else {
            self.userName = "" // Placeholder, wenn kein Name verfügbar ist
        }
    }
}

struct Onboarding_ProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        Onboarding_ProfilePicture()
    }
}

// Custom ImagePicker Component
struct OnboardingImagePicker: UIViewControllerRepresentable {
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
        let parent: OnboardingImagePicker

        init(_ parent: OnboardingImagePicker) {
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
