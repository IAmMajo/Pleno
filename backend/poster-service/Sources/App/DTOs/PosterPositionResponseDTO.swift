//
//  PosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
public struct PosterPositionResponseDTO: Codable {
    public var id: UUID?
    public var posterId: UUID
    public var responsibleUserId: UUID
    public var latitude: Double
    public var longitude: Double
    public var isDisplayed: Bool
    public var imageUrl: String 
    public var expiresAt:Date
    public var postedAt:Date

    public init(id: UUID?, posterId: UUID, responsibleUserId: UUID, latitude: Double, longitude: Double, isDisplayed: Bool, imageUrl: String,expiresAt:Date,postedAt:Date) {
        self.id = id
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.isDisplayed = isDisplayed
        self.imageUrl = imageUrl
        self.expiresAt = expiresAt
        self.postedAt = postedAt
    }
}
