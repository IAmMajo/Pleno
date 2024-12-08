package net.ipv64.kivop.dtos

data class JWTPayloadDTO (
    var userID : UUID?,
    var exp : Date,
    var isAdmin : Boolean?,
)
