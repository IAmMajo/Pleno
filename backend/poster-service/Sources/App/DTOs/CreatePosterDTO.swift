//
//  CreatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation
import Vapor

public struct CreatePosterDTO: Codable {
    public var name: String
    public var description: String?
    public var image: File
    
    public init(name: String, description: String? = nil, image: File ) {
        self.name = name
        self.description = description
        self.image = image
    }
}

