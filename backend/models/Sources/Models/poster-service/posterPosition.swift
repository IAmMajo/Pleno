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
    
    @Parent(key: "poster_id")
    public var poster: Poster
    
    @Field(key: "latitude")
    public var latitude: Double

    @Field(key: "longitude")
    public var longitude: Double

    @Field(key: "posted_at")
    public var posted_at: Date?
    
    @OptionalParent(key: "posted_by")
    public var posted_by: Identity?
    
    @Field(key: "expires_at")
    public var expires_at: Date
    
    @Field(key: "removed_at")
    public var removed_at: Date?
    
    @OptionalParent(key: "removed_by")
    public var removed_by: Identity?
    
    @Field(key:"image")
    public var image: Data?
    
    @Children(for: \.$poster_position)
    public var responsibilities: [PosterPositionResponsibilities]
    
    public init() { }

public init(
    id: UUID? = nil,
    posterId: UUID,
    latitude: Double,
    longitude: Double,
    expiresAt: Date
) {
    self.id = id
    self.latitude = round(latitude * 1_000_000) / 1_000_000
    self.longitude = round(longitude * 1_000_000) / 1_000_000
    self.$poster.id = posterId
    self.expires_at = expiresAt
    self.image = nil
    self.posted_at = nil
    self.$posted_by.id = nil
    self.removed_at = nil
    self.$removed_by.id = nil
}

}
