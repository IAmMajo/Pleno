import Foundation

public struct UpdatePosterPositionDTO: Codable {
    public var latitude: Double?
    public var longitude: Double?
    public var isDisplayed: Bool?
    public var imageBase64: String? // Optionaler Base64-String für das Bild
    public var expiresAt:Date


    public init(latitude: Double?, longitude: Double?, isDisplayed: Bool?, imageBase64: String?, expiresAt: Date) {
        self.latitude = latitude
        self.longitude = longitude
        self.isDisplayed = isDisplayed
        self.imageBase64 = imageBase64
        self.expiresAt = expiresAt

    }
}
