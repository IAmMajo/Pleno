import Foundation

public struct PosterPositionShortResponseDTO: Codable {
    public var id: UUID
    public var posterId: UUID?
    public var expiresAt: Date
    public var status: String

    public init(id: UUID, posterId: UUID? = nil, expiresAt: Date, status: String) {
        self.id = id
        self.posterId = posterId
        self.expiresAt = expiresAt
        self.status = status
    }
}
