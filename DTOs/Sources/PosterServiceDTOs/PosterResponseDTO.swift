//
//  PosterResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation

public struct PosterResponseDTO: Codable {
    public var id: UUID?
    public var name: String
    public var description: String?
    public var imageUrl: String
   

    public init(id: UUID?, name: String, description: String?, imageUrl: String) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
       
    }
}

