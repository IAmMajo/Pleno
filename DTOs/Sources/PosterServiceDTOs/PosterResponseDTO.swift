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
    public var imageBase64: String // Hinzugefügt

    public init(id: UUID?, name: String, description: String?, imageBase64: String) {
        self.id = id
        self.name = name
        self.description = description
        self.imageBase64 = imageBase64
    }
}

