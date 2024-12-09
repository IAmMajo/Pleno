import Foundation

public struct GetRideOverviewDTO: Codable {
    public var id: UUID?
    public var name: String
    public var description: String?
    public var starts: Date
    
    public init(id: UUID?, name: String, description: String? = nil, starts: Date) {
        self.id = id
        self.name = name
        self.description = description
        self.starts = starts
    }
}
