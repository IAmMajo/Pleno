//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
import Vapor

public struct UpdatePosterPositionDTO: Codable {
    
    public var posterId: UUID?
    public var latitude: Double?
    public var longitude: Double?
    public var expires_at:Date?
    public var responsible_users: [UUID]?
    public var image: File?
    

    public init(
                posterId: UUID? = nil,
                latitude: Double?,
                longitude: Double?,
                imageUrl: String?,
                expiresAt: Date?,
                responsibleUsers:[UUID]?,
                image: File?
                )
    {
        self.latitude = round((latitude ?? 0) * 1_000_000) / 1_000_000
        self.longitude = round(longitude ?? 0 * 1_000_000) / 1_000_000
        self.posterId = posterId
        self.expires_at = expiresAt
        self.responsible_users = responsibleUsers
        self.image = image
    }
}



