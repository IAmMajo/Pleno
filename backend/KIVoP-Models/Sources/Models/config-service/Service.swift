//
//  services.swift
//  config-service
//
//  Created by Dennis Sept on 30.10.24.
//
import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.
public final class Service: Model, @unchecked Sendable {
    public static let schema = "services"
    
    @ID(key: .id)
    public var id: UUID?

    @Field(key: "name")
    public var name: String

    public init() { }

    public init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }
    
}

