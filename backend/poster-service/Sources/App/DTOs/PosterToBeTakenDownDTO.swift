//
//  PosterToBeTakenDown.swift
//  poster-service
//
//  Created by Dennis Sept on 28.11.24.
//

import Foundation

public struct PosterToBeTakenDownDTO: Codable {
    public var id: UUID?
    public var name: String
    public var description: String?
    public var imageUrl: String
    public var posterDeletionInterval:Int

    public init(id: UUID?, name: String, description: String?, imageUrl: String,posterDeletionInterval:Int) {
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.posterDeletionInterval = posterDeletionInterval
    }
}
