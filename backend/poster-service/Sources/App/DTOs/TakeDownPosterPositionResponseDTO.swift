//
//  TakeDownPosterPositionResponseDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//


import Foundation


public struct TakeDownPosterPositionResponseDTO: Codable {
    public var poster_position: UUID
    public var removed_at: Date
    public var removed_by: UUID
   
    public init(
        posterPosition:UUID,
        removedAt: Date,
        removedBy:UUID
                )
    {
        self.poster_position = posterPosition
        self.removed_at = removedAt
        self.removed_by = removedBy
    }
}
