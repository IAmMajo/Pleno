//
//  CreatePosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//

import Foundation


public struct CreatePosterPositionDTO: Codable {
    
    public var posterId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var responsibleUsers: [UUID]
    public var expiresAt: Date
    
    public init(
                posterId: UUID? = nil,
                latitude: Double,
                longitude: Double,
                responsibleUsers: [UUID],
                expiresAt: Date
                )
    {
        self.posterId = posterId
        self.latitude = round(latitude * 1_000_000) / 1_000_000
        self.longitude = round(longitude * 1_000_000) / 1_000_000
        self.responsibleUsers = responsibleUsers
        self.expiresAt = expiresAt
    }
}


