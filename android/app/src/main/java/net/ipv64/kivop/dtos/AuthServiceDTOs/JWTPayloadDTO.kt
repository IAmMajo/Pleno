package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class JWTPayloadDTO (
    var userID : UUID?,
    var exp : LocalDateTime,
    var isAdmin : Boolean?,
)
