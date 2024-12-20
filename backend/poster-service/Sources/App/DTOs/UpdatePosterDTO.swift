//
//  UpdatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Vapor
public struct UpdatePosterDTO: Codable {
    public var name: String?
    public var description: String?
    public var image: File?
    
    public init(name: String? = nil, description: String? = nil, image: File? = nil) {
        self.name = name
        self.description = description
        self.image = image
    }
}
