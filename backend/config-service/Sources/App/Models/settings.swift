//
//  settings.swift
//  config-service
//
//  Created by Dennis Sept on 30.10.24.
//
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
final class Setting: Model, @unchecked Sendable {
    static let schema = "settings"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "key")
    var key: String
    
    @Field(key: "value")
    var value: String


    init() { }

    init(id: UUID? = nil, key: String, value: String) {
        self.id = id
        self.key = key
        self.value = value
    }

}

