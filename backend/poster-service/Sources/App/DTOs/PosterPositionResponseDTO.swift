//
//  PosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation

public struct PosterPositionResponseDTO: Codable {
    public var id: UUID
    public var posterId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var posted_by:UUID?
    public var postedAt:Date?
    public var expires_at:Date
    public var removed_by: UUID?
    public var removed_at: Date?
    public var imageUrl: String?
    public var responsible_users: [UUID]
    public var status: String
    public init(
        id: UUID,
        posterId: UUID? = nil,
        latitude: Double,
        longitude: Double,
        postedBy:UUID? = nil,
        postedAt:Date? = nil,
        expiresAt: Date,
        removedBy:UUID? = nil,
        removedAt:Date? = nil,
        imageUrl: String? = nil,
        responsibleUsers:[UUID],
        status:String
    )
    {
        self.id = id
        self.posterId = posterId
        self.latitude = round(latitude * 1_000_000) / 1_000_000
        self.longitude = round(longitude * 1_000_000) / 1_000_000
        self.posted_by = postedBy
        self.postedAt = postedAt
        self.expires_at = expiresAt
        self.removed_by = removedBy
        self.removed_at = removedAt
        self.imageUrl = imageUrl
        self.responsible_users = responsibleUsers
        self.status = status
    }
}
