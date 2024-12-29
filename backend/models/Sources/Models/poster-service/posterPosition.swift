//
//  posterPosition.swift
//  models
//
//  Created by Dennis Sept on 26.11.24.
//
import Fluent
import Foundation


public final class PosterPosition: Model,@unchecked Sendable {
    public static let schema = "poster_positions"

    @ID(key: .id)
    public var id: UUID?
    
    @OptionalParent(key: "poster_id")
    public var poster: Poster?
    
    @Field(key: "latitude")
    public var latitude: Double

    @Field(key: "longitude")
    public var longitude: Double

    @Timestamp(key: "posted_at", on: .create)
    public var posted_at: Date?
    
    @OptionalParent(key: "posted_by")
    public var posted_by: Identity?
    
    @Timestamp(key: "expires_at", on: .update)
    public var expires_at: Date?
    
    @Timestamp(key: "removed_at", on: .create)
    public var removed_at: Date?
    
    @OptionalParent(key: "removed_by")
    public var removed_by: Identity?
    
    @Field(key:"image_url")
    public var image_url: String?
    
    @Children(for: \.$poster_position)
    public var responsibilities: [PosterPositionResponsibilities]
    
    public init() { }

public init(
    id: UUID? = nil,
    posterId: UUID? = nil,
    latitude: Double,
    longitude: Double,
    expiresAt: Date
) {
    self.id = id
    self.latitude = round(latitude * 1_000_000) / 1_000_000
    self.longitude = round(longitude * 1_000_000) / 1_000_000
    self.$poster.id = posterId
    self.expires_at = expiresAt
}

}
