import Foundation
import Models

public struct GetRideDetailDTO: Codable {
    public var id: UUID?
    public var name: String
    public var description: String?
    public var starts: Date
    public var participants: [GetParticipantDTO]
    public var latitude: Float
    public var longitude: Float
    public var participantSum: Int
    public var seatsSum: Int
    public var passengersSum: Int
    
    public init(id: UUID? = nil, name: String, description: String? = nil, starts: Date, participants: [GetParticipantDTO], latitude: Float, longitude: Float, participantSum: Int, seatsSum: Int, passengersSum: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
        self.participants = participants
        self.latitude = latitude
        self.longitude = longitude
        self.participantSum = participantSum
        self.seatsSum = seatsSum
        self.passengersSum = passengersSum
    }
}
