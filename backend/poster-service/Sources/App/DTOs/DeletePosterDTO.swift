//
//  DeletePosterDTO.swift
//  poster-service
//
//  Created by Dennis Sept on 02.12.24.
//
import Foundation

public struct DeleteDTO: Codable {
    public var ids: [UUID]
    
    public init (ids:[UUID]) {
        self.ids = ids
    }
}
