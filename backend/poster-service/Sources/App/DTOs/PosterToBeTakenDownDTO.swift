//
//  PosterToBeTakenDown.swift
//  poster-service
//
//  Created by Dennis Sept on 28.11.24.
//

import Foundation

public struct PosterToBeTakenDownDTO: Codable {
    public var posterId: UUID
    public var responsibleUserId: UUID
    public var latitude: Double
    public var longitude: Double
    public var imageURL: String
    public var expiresAt:Date
    
    public init(posterId: UUID, responsibleUserId: UUID, latitude: Double, longitude: Double, isDisplayed: Bool, imageURL: String,expiresAt:Date) {
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
        self.expiresAt = expiresAt
    }
}
