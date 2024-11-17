@preconcurrency import JWT
public struct JWTPayloadDTO: JWTPayload, Authenticatable, Sendable {
    public var userID : Uuid?
    public var exp : ExpirationClaim
    public var isAdmin : Boolean?
    public func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}
