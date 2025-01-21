import Foundation

public struct GetEventDetailDTO: Codable {
    public var id: UUID
    public var name: String
    public var description: String?
    public var starts: Date
    public var ends: Date
    public var latitude: Float
    public var longitude: Float
    public var participations: [GetEventParticipationDTO]
    public var userWithoutFeedback: [GetUserWithoutFeedbackDTO]
    public var countRideInterested: Int
    public var countEmptySeats: Int
    
    public init(id: UUID, name: String, description: String? = nil, starts: Date, ends: Date, latitude: Float, longitude: Float, participations: [GetEventParticipationDTO], userWithoutFeedback: [GetUserWithoutFeedbackDTO], countRideInterested: Int, countEmptySeats: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
        self.ends = ends
        self.latitude = latitude
        self.longitude = longitude
        self.participations = participations
        self.userWithoutFeedback = userWithoutFeedback
        self.countRideInterested = countRideInterested
        self.countEmptySeats = countEmptySeats
    }
}

