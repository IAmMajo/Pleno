//
//  UpdatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation

public struct UpdatePosterPositionDTO: Codable {
    
    public var posterId: UUID?
    public var latitude: Double?
    public var longitude: Double?
    public var expires_at:Date?
    public var responsible_users: [UUID]?
    public var image: Data?
    

    public init(
                posterId: UUID? = nil,
                latitude: Double? = nil,
                longitude: Double? = nil,
                imageUrl: String? = nil,
                expiresAt: Date? = nil,
                responsibleUsers:[UUID]? = nil,
                image: Data? = nil
                )
    {
        self.latitude = latitude 
        self.longitude = longitude 
        self.posterId = posterId
        self.expires_at = expiresAt
        self.responsible_users = responsibleUsers
        self.image = image
    }
}



