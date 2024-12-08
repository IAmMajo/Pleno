package net.ipv64.kivop.dtos

data class JWTPayloadDTO (
    var userID : Uuid?
    var exp : Date
    var isAdmin : Boolean?
)
