package net.ipv64.kivop.dtos

data class UserProfileDTO (
    var uid : Uuid?,
    var email : String?,
    var name : String?,
    var profileImage : Data?,
    var isAdmin : Boolean?,
    var isActive : Boolean?,
    var createdAt : Date?,
)
