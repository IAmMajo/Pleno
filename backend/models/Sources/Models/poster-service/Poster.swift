//
//  posters.swift
//  models
//
//  Created by Dennis Sept on 26.11.24.
//

import Fluent
import Foundation

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Poster: Model, @unchecked Sendable {
    public static let schema = "Poster"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    @OptionalField(key: "description")
    public var description: String?

    @Field(key: "image_url")
    public var image_url: String
    
   
    public init() { }

    public init(id: UUID? = nil, name: String,  description: String?, imageUrl: String) {
        self.id = id
        self.name = name
        self.description = description
        self.image_url = imageUrl
    }
    
}


    
