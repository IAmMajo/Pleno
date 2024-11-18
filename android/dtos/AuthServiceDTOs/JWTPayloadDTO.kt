public data class JWTPayloadDTO {
    public var userID : Uuid?
    public var exp : Date
    public var isAdmin : Boolean?
}
