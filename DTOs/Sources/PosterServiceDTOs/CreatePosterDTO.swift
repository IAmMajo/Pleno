//
//  CreatePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 26.11.24.
//
import Foundation


public struct CreatePosterDTO: Codable {
    public var name: String
    public var description: String?
    public var image: Data 

    public init(name: String, description: String?, image: Data) {
        self.name = name
        self.description = description
        self.image = image
    }
}

