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

// Ermöglicht das Auswählen eines Bildes aus der Galerie oder Kamera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?  // Speichert das ausgewählte Bild
    var sourceType: UIImagePickerController.SourceType  // Definiert Quelle (Kamera oder Galerie)
    var onImagePicked: (UIImage?) -> Void  // Callback, um das Bild weiterzugeben

    // Erstellt und konfiguriert den UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator  // Setzt den Koordinator als Delegate
        picker.sourceType = sourceType  // Wählt Kamera oder Galerie
        picker.allowsEditing = true  // Erlaubt das Zuschneiden des Bildes
        return picker
    }

    // Aktualisiert den Picker, falls sich die Quelle ändert
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        uiViewController.sourceType = sourceType
    }

    // Erstellt den Koordinator für die Delegation der Auswahl-Events
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Koordinator für die Kommunikation zwischen SwiftUI und UIKit
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        // Wird aufgerufen, wenn der Nutzer ein Bild auswählt
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.onImagePicked(image)  // Übergibt das ausgewählte Bild
            }
            picker.dismiss(animated: true)
        }

        // Wird aufgerufen, wenn der Nutzer den Picker ohne Auswahl schließt
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
