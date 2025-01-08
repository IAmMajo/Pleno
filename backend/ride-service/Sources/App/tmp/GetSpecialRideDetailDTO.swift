/**
 id uuid [primary key]
 latitude float [not null]
 longitude float [not null]
 emptySeats int [not null]
 name text
 description text
 vehicle_description text
 starts datetime

 created_at timestamp
 updated_at timestamp
 */

// liste an namen der teilnehmer inkl status ob angefragt/angenommen je nach dem ob man fahrer ist oder nicht [GetRiderDTO]

import Foundation

public struct GetSpecialRideDetailDTO: Codable {
    public var id: UUID?
    public var driverName: String
    public var isSelfDriver: Bool
    public var name: String
    public var description: String?
    public var vehicleDescription: String?
    public var starts: Date
    public var ends: Date
    public var startLatitude: Float
    public var startLongitude: Float
    public var destinationLatitude: Float
    public var destinationLongitude: Float
    public var emptySeats: UInt8
    public var riders: [GetRiderDTO]
    
    public init(id: UUID? = nil, driverName: String, isSelfDriver: Bool, name: String, description: String? = nil, vehicleDescription: String? = nil, starts: Date, ends: Date, startLatitude: Float, startLongitude: Float, destinationLatitude: Float, destinationLongitude: Float, emptySeats: UInt8, riders: [GetRiderDTO]) {
        self.id = id
        self.driverName = driverName
        self.isSelfDriver = isSelfDriver
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
        self.riders = riders
    }
    
}
