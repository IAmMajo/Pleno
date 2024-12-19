//
//  HangPosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//

import Foundation


public struct HangPosterPositionResponseDTO: Codable {
    public var poster_position: UUID
    public var posted_at: Date
    public var posted_by: UUID
    public var image_url:String
    public init(
        posterPosition:UUID,
        postedAt: Date,
        postedBy:UUID,
        imageUrl:String
    )
    {
        self.poster_position = posterPosition
        self.posted_at = postedAt
        self.posted_by = postedBy
        self.image_url = imageUrl
    }
}
