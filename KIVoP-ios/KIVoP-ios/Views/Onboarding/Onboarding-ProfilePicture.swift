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

struct Onboarding_ProfilePicture: View {
    // Das ausgewählte Bild wird über ein Binding aus einer übergeordneten View übergeben
    @Binding var selectedImage: UIImage?
    // Steuert die Anzeige des ImagePickers
    @State private var showImagePicker = false
    // Definiert, ob Kamera oder Galerie geöffnet wird
    @State private var imagePickerType: ImagePickerType?

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrundfarbe für eine konsistente Darstellung im System-Design
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 30) {
                    // Profilbild-Anzeige oder Platzhalter-Kreis, falls kein Bild vorhanden ist
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

                    // Auswahlmöglichkeiten: Kamera oder Galerie
                    HStack(spacing: 50) {
                        // Kamera-Button
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

                        // Galerie-Button
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
            // Zeigt den ImagePicker als Sheet an, basierend auf der Auswahl (Kamera oder Galerie)
            .sheet(item: $imagePickerType) { pickerType in
                ImagePicker(selectedImage: $selectedImage, sourceType: pickerType.type)
            }
        }
    }

    // MARK: - Wrapper für SourceType (ermöglicht die Nutzung in .sheet als Identifiable)
    struct ImagePickerType: Identifiable {
        let id = UUID()
        let type: UIImagePickerController.SourceType
    }

    // MARK: - ImagePicker (UIKit-Integration für Kamera & Galerie)
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var selectedImage: UIImage?
        var sourceType: UIImagePickerController.SourceType

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            picker.sourceType = sourceType
            picker.allowsEditing = true // Erlaubt das Bearbeiten des Bildes vor der Auswahl
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        // MARK: - Coordinator zur Verarbeitung der Bildauswahl
        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }

            // Wird aufgerufen, wenn der Benutzer ein Bild ausgewählt hat
            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
                if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                    parent.selectedImage = image
                }
                picker.dismiss(animated: true) // Schließt den Picker nach der Auswahl
            }

            // Wird aufgerufen, wenn der Benutzer den Picker ohne Auswahl verlässt
            func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
                picker.dismiss(animated: true)
            }
        }
    }
}
