// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Fluent
import Foundation

public final class SpecialRide: Model, @unchecked Sendable {
    public static let schema = "special_rides"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "user_id")
    public var user: User
    
    @Field(key: "name")
    public var name: String
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "vehicle_description")
    public var vehicleDescription: String?
    
    @Field(key: "starts")
    public var starts: Date
    
    @Field(key: "ends")
    public var ends: Date
    
    @Field(key: "start_latitude")
    public var startLatitude: Float
    
    @Field(key: "start_longitude")
    public var startLongitude: Float
    
    @Field(key: "destination_latitude")
    public var destinationLatitude: Float
    
    @Field(key: "destination_longitude")
    public var destinationLongitude: Float
    
    @Field(key: "emptySeats")
    public var emptySeats: UInt8
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, userID: User.IDValue, name: String, description: String? = nil, vehicleDescription: String? = nil, starts: Date, ends: Date, startLatitude: Float, startLongitude: Float, destinationLatitude: Float, destinationLongitude: Float, emptySeats: UInt8, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$user.id = userID
        self.name = name
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.starts = starts
        self.ends = ends
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.destinationLatitude = destinationLatitude
        self.destinationLongitude = destinationLongitude
        self.emptySeats = emptySeats
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}
