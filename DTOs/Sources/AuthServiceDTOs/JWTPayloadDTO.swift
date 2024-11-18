import Foundation

public struct JWTPayloadDTO: Codable {
    public var userID: UUID?
    public var exp: Date
    public var isAdmin: Bool?
    
    public init(userID: UUID, exp: Date, isAdmin: Bool? = false) {
        self.userID = userID
        self.exp = exp
        self.isAdmin = isAdmin
    }
}

