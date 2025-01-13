import Foundation

public struct GetRiderDTO: Codable {
    public var id: UUID
    public var name: String
    public var lat: Float
    public var long: Float
    public var status: Bool
    
    public init(id: UUID, name: String, lat: Float, long: Float, status: Bool){
        self.id = id
        self.name = name
        self.lat = lat
        self.long = long
        self.status = status
    }
}
