/**
 id uuid [primary key]
 emptySeats int [not null]
 name text
 starts datetime

 created_at timestamp
 updated_at timestamp
 */

// belegte plätze
// mein status ob fahrer / pending / accepted / none

import Foundation

public struct GetSpecialRideDTO: Codable {
    public var id: UUID?
    public var name: String
    public var starts: Date
    public var ends: Date
    public var emptySeats: UInt8
    public var allocatedSeats: UInt8
    public var isSelfDriver: Bool
    public var isSelfAccepted: Bool
    
    public init(id: UUID? = nil, name: String, starts: Date, ends: Date, emptySeats: UInt8, allocatedSeats: UInt8, isSelfDriver: Bool, isSelfAccepted: Bool) {
        self.id = id
        self.name = name
        self.starts = starts
        self.ends = ends
        self.emptySeats = emptySeats
        self.allocatedSeats = allocatedSeats
        self.isSelfDriver = isSelfDriver
        self.isSelfAccepted = isSelfAccepted
    }
}
