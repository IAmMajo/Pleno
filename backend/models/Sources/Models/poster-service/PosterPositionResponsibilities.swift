//
//  PosterPositionResponsibilities.swift
//  models
//
//  Created by Dennis Sept on 16.12.24.
//


import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class PosterPositionResponsibilities: Model, @unchecked Sendable {
    public static let schema = "poster_position_responsibilities"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key:"user_id")
    public var user: User

    @Parent(key:"poster_position_id")
    public var poster_position: PosterPosition
    
    public init() { }

    public init(id: UUID? = nil, userID:UUID,posterPositionID:UUID ) {
        self.id = id
        self.$user.id = userID
        self.$poster_position.id = posterPositionID
    }
    
}


    
