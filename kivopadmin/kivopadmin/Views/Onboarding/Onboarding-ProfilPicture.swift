// This file is licensed under the MIT-0 License.
import SwiftUI
import UIKit

// Ansicht für die Auswahl eines Profilbildes während des Onboardings.
struct Onboarding_ProfilePicture: View {
    @Binding var selectedImage: UIImage? // Das ausgewählte Bild wird nach außen weitergegeben
    @State private var showImagePicker = false // Steuert die Anzeige des Image Pickers
    @State private var imagePickerType: ImagePickerType? // Optional, um den Typ der Bildauswahl zu kontrollieren

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrundfarbe der Ansicht
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
                                .clipShape(Circle()) // Bild in Kreisform zuschneiden
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 200, height: 200) // Platzhalter, falls kein Bild vorhanden ist
                        }
                    }

                    // Auswahlmöglichkeiten für Kamera oder Galerie
                    HStack(spacing: 50) {
                        Button(action: {
                            imagePickerType = ImagePickerType(type: .camera) // Kamera als Quelle setzen
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
                            imagePickerType = ImagePickerType(type: .photoLibrary) // Galerie als Quelle setzen
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
            // Präsentiert das ImagePicker-Modal basierend auf dem ausgewählten Typ (Kamera oder Galerie)
            .sheet(item: $imagePickerType) { pickerType in
                ImagePicker(selectedImage: $selectedImage, sourceType: pickerType.type)
            }
        }
    }

    // MARK: - Hilfsstruktur zur Speicherung des Quelltyps für den ImagePicker
    struct ImagePickerType: Identifiable {
        let id = UUID() // Eindeutige Identifikation für das Sheet
        let type: UIImagePickerController.SourceType // Kamera oder Galerie
    }

    // MARK: - ImagePicker: Wrapper für die native UIImagePickerController-Nutzung
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage? // Übergibt das ausgewählte Bild zurück
        var sourceType: UIImagePickerController.SourceType // Typ der Bildquelle

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            picker.allowsEditing = true // Ermöglicht die Bearbeitung des Bildes
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self) // Erstellt einen Koordinator zur Verarbeitung der Bildauswahl
        }

        // MARK: - Koordinator zur Handhabung der Bildauswahl
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            // Methode wird aufgerufen, wenn ein Bild ausgewählt wurde
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    parent.selectedImage = image // Speichert das ausgewählte Bild
                }
                picker.dismiss(animated: true) // Schließt den Picker
            }

            // Methode wird aufgerufen, wenn der Benutzer den Picker abbricht
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
