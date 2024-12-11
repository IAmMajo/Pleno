import Foundation
public struct PosterPositionResponseDTO: Codable {
    public var id: UUID?
    public var posterId: UUID
    public var responsibleUserId: UUID
    public var latitude: Double
    public var longitude: Double
    public var isDisplayed: Bool
    public var imageBase64: String // Hinzugefügt
    public var expiresAt:Date
    public var postedAt:Date

    public init(id: UUID?, posterId: UUID, responsibleUserId: UUID, latitude: Double, longitude: Double, isDisplayed: Bool, imageBase64: String, expiresAt: Date, postedAt: Date) {
        self.id = id
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.isDisplayed = isDisplayed
        self.imageBase64 = imageBase64
        self.expiresAt = expiresAt
        self.postedAt = postedAt
    }
}
