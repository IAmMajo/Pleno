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

public final class EventRide: Model, @unchecked Sendable {
    public static let schema = "event_rides"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "event_id")
    public var event: PlenoEvent
    
    @Parent(key: "participant_id")
    public var participant: EventParticipant
    
    @Field(key: "starts")
    public var starts: Date
    
    @Field(key: "latitude")
    public var latitude: Float
    
    @Field(key: "longitude")
    public var longitude: Float
    
    @Field(key: "emptySeats")
    public var emptySeats: UInt8
    
    @Field(key: "description")
    public var description: String?
    
    @Field(key: "vehicle_description")
    public var vehicleDescription: String?
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, eventID: PlenoEvent.IDValue, participantID: EventParticipant.IDValue, starts: Date, latitude: Float, longitude: Float, emptySeats: UInt8, description: String? = nil, vehicleDescription: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$event.id = eventID
        self.$participant.id = participantID
        self.starts = starts
        self.latitude = latitude
        self.longitude = longitude
        self.emptySeats = emptySeats
        self.description = description
        self.vehicleDescription = vehicleDescription
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
