//
//  PosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation

public struct PosterPositionResponseDTO: Codable {
    public var id: UUID
    public var posterId: UUID?
    public var latitude: Double
    public var longitude: Double
    public var postedBy:String?
    public var postedAt:Date?
    public var expiresAt:Date
    public var removedBy: String?
    public var removedAt: Date?
    public var imageUrl: String?
    public var responsibleUsers: [ResponsibleUsersDTO]
    public var status: String
    public init(
        id: UUID,
        posterId: UUID? = nil,
        latitude: Double,
        longitude: Double,
        postedBy:String? = nil,
        postedAt:Date? = nil,
        expiresAt: Date,
        removedBy:String? = nil,
        removedAt:Date? = nil,
        imageUrl: String? = nil,
        responsibleUsers:[ResponsibleUsersDTO],
        status:String
    )
    {
        self.id = id
        self.posterId = posterId
        self.latitude = round(latitude * 1_000_000) / 1_000_000
        self.longitude = round(longitude * 1_000_000) / 1_000_000
        self.postedBy = postedBy
        self.postedAt = postedAt
        self.expiresAt = expiresAt
        self.removedBy = removedBy
        self.removedAt = removedAt
        self.imageUrl = imageUrl
        self.responsibleUsers = responsibleUsers
        self.status = status
    }
}

public struct ResponsibleUsersDTO: Codable {
    public var id: UUID
    public var name: String
   
    public init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}






