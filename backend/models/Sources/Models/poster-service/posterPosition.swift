//
//  posterPosition.swift
//  models
//
//  Created by Dennis Sept on 26.11.24.
//
import Fluent
import Foundation

public final class PosterPosition: Model,@unchecked Sendable {
    public static let schema = "PosterPosition"

    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "poster_id")
    public var poster: Poster
    
    @Parent(key: "responsible_user_id")
    public var responsibleUser: User

    @Field(key: "latitude")
    public var latitude: Double

       @Field(key: "longitude")
    public var longitude: Double

    @Field(key: "is_Displayed")
    public var is_Displayed: Bool

    @Timestamp(key: "posted_at", on: .create)
    public var posted_at: Date?
    
    @Timestamp(key: "expires_at", on: .update)
    public var expires_at: Date?
    
    @Field(key:"image_url")
    public var image_url: String

    public init() { }

public init(
    id: UUID? = nil,
    posterId: UUID,
    responsibleUserID: UUID,
    latitude: Double,
    longitude: Double,
    imageUrl: String,
    expiresAt: Date
) {
    self.id = id
    self.latitude = latitude
    self.longitude = longitude
    self.$poster.id = posterId 
    self.$responsibleUser.id = responsibleUserID 
    self.posted_at = Date()
    self.is_Displayed = true
    self.expires_at = expiresAt
    self.image_url = imageUrl
}

}
