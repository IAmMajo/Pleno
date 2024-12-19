//
//  HangPosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//

import Foundation
import Vapor

public struct HangPosterPositionDTO: Codable {
    public var user: UUID
    public var poster_position: UUID
    public var image:File
    public init(
        user:UUID,
        posterPosition:UUID,
        image:File
                )
    {
        self.user = user
        self.poster_position = posterPosition
        self.image = image
    }
}
