import Fluent
import Foundation

public final class PosterPositionResponsibilities: Model, @unchecked Sendable {
    public static let schema = "poster_position_responsibilities"
    
    @ID(key: .id)
    public var id: UUID?

    @Parent(key:"user_id")
    public var user: User

    @Parent(key:"poster_position_id")
    public var poster_position: PosterPosition
    
    public init() { }

    public init(id: UUID? = nil, userID:UUID,posterPositionID:UUID ) {
        self.id = id
        self.$user.id = userID
        self.$poster_position.id = posterPositionID
    }
    
}


    
