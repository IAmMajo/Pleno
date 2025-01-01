import Fluent
import Vapor
import Models
@preconcurrency import JWT

public struct JWTPayloadDTO: JWTPayload, Authenticatable, Sendable, Content {
    public var userID: UUID?
    public var exp: ExpirationClaim
    public var isAdmin: Bool?
    
    public init(userID: UUID!, exp: Date, isAdmin: Bool? = false) {
        self.userID = userID
        self.exp = ExpirationClaim(value: exp)
        self.isAdmin = isAdmin
    }
    
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
