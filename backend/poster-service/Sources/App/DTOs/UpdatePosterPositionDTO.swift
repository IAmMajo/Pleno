//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
import Vapor
public struct UpdatePosterPositionDTO: Codable {
    public var latitude: Double?
    public var longitude: Double?
    public var isDisplayed: Bool?
    public var image: File? 
    public var expiresAt:Date?
    public var responsibleUserId: UUID?
    public var posterId: UUID?


    public init(posterId:UUID?,responsibleUserId:UUID?,latitude: Double?, longitude: Double?, isDisplayed: Bool?, image: File?,expiresAt:Date?) {
        self.posterId = posterId
        self.responsibleUserId = responsibleUserId
        self.latitude = latitude
        self.longitude = longitude
        self.isDisplayed = isDisplayed
        self.image = image
        self.expiresAt = expiresAt

    }
}
