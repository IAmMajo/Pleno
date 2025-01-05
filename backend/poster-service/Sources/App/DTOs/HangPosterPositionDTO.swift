//
//  HangPosterPositionDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 18.12.24.
//

import Foundation
import Vapor

public struct HangPosterPositionDTO: Codable {
    public var posterPosition: UUID
    public var image:File
    
    public init(
        posterPosition:UUID,
        image:File
                )
    {
        self.posterPosition = posterPosition
        self.image = image
    }
}
