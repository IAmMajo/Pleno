//
//  HangPosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//

import Foundation
import Vapor

public struct HangPosterPositionDTO: Codable {
    public var poster_position: UUID
    public var image:File
    public init(
        posterPosition:UUID,
        image:File
                )
    {
        self.poster_position = posterPosition
        self.image = image
    }
}
