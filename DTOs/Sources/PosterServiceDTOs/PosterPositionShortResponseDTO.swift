import Foundation

public struct PosterPositionShortResponseDTO: Codable {
    public var id: UUID
    public var posterId: UUID?
    public var expires_at: Date
    public var status: String

    public init(id: UUID, posterId: UUID? = nil, expiresAt: Date, status: String) {
        self.id = id
        self.posterId = posterId
        self.expires_at = expiresAt
        self.status = status
    }
}
