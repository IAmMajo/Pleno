//
//  HangPosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//

import Foundation


public struct HangPosterPositionDTO: Codable {
    public var user: UUID
    public var poster_position: UUID
    public init(
        user:UUID,
        posterPosition:UUID
                )
    {
        self.user = user
        self.poster_position = posterPosition
    }
}
