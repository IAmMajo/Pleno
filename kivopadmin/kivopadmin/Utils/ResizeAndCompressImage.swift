import UIKit

/// Verkleinert und komprimiert ein Bild, das als `Data` vorliegt.
/// Gibt garantiert ein `Data` zurück, auch wenn der Verkleinerungsprozess fehlschlägt.
/// - Parameters:
///   - imageData: Das Originalbild als `Data`.
///   - maxWidth: Die maximale Breite des Bildes.
///   - maxHeight: Die maximale Höhe des Bildes.
///   - compressionQuality: Die Kompressionsqualität (0.0 - 1.0).
/// - Returns: Das verkleinerte und komprimierte Bild als `Data`.
func resizeAndCompressImageData(
    imageData: Data,
    maxWidth: CGFloat,
    maxHeight: CGFloat,
    compressionQuality: CGFloat
) -> Data {
    // Versuche, `Data` in ein `UIImage` zu konvertieren
    guard let originalImage = UIImage(data: imageData) else {
        print("Ungültiges Bildformat. Rückgabe der ursprünglichen Daten.")
        return imageData
    }

    // Berechne den Skalierungsfaktor
    let aspectWidth = maxWidth / originalImage.size.width
    let aspectHeight = maxHeight / originalImage.size.height
    let scaleFactor = min(aspectWidth, aspectHeight)
    
    // Neue Bildgröße basierend auf dem Skalierungsfaktor
    let newSize = CGSize(
        width: originalImage.size.width * scaleFactor,
        height: originalImage.size.height * scaleFactor
    )
    
    // Erstelle ein neues Grafik-Kontext für die skalierte Größe
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    originalImage.draw(in: CGRect(origin: .zero, size: newSize))
    let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // Versuche, das Bild zu komprimieren, oder gib die ursprünglichen Daten zurück
    if let resizedImage = resizedImage,
       let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality) {
        print(compressedData)
        return compressedData
    } else {
        print("Fehler beim Verkleinern oder Komprimieren. Rückgabe der ursprünglichen Daten.")
        return imageData
    }
}
