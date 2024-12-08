//
//  CreatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//

import Foundation
import Vapor
public struct CreatePosterPositionDTO: Codable {
    public var posterId: UUID
    public var responsibleUserId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var image: File?
    public var expiresAt:Date

    public init(posterId: UUID, responsibleUserId: UUID?, latitude: Double, longitude: Double, isDisplayed: Bool, image: File?,expiresAt:Date) {
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
        self.expiresAt = expiresAt
    }
}
