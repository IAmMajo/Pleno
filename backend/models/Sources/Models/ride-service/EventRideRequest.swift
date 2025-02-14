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

public final class EventRideRequest: Model, @unchecked Sendable {
    public static let schema = "event_ride_requests"
    
    @ID(key: .id)
    public var id: UUID?
    
    @Parent(key: "event_ride_id")
    public var ride: EventRide
    
    @Parent(key: "interested_party_id")
    public var interestedParty: EventRideInterestedParty
    
    @Field(key: "accepted")
    public var accepted: Bool
    
    @Timestamp(key: "created_at", on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: "updated_at", on: .update)
    public var updatedAt: Date?
    
    public init(){}
    
    public init(id: UUID? = nil, rideID: EventRide.IDValue, interestedPartyID: EventRideInterestedParty.IDValue, accepted: Bool, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.$ride.id = rideID
        self.$interestedParty.id = interestedPartyID
        self.accepted = accepted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
   
}
