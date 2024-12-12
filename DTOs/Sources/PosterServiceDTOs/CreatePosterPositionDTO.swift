import Foundation

public struct CreatePosterPositionDTO: Codable {
    public var posterId: UUID
    public var responsibleUserId: UUID
    public var latitude: Double
    public var longitude: Double
    public var imageBase64: String // Bild als Base64-String
    public var expiresAt:Date

    public init(posterId: UUID, responsibleUserId: UUID, latitude: Double, longitude: Double, isDisplayed: Bool, imageBase64: String, expiresAt: Date) {
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.imageBase64 = imageBase64
        self.expiresAt = expiresAt
    }
}
