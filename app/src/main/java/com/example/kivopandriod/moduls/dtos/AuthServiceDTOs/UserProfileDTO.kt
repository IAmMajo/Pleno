public data class UserProfileDTO {
    public var uid : Uuid?
    public var email : String?
    public var name : String?
    public var profileImage : Data?
    public var isAdmin : Boolean?
    public var isActive : Boolean?
    public var createdAt : Date?
}
