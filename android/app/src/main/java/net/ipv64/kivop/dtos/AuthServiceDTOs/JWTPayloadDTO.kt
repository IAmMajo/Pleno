package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class JWTPayloadDTO(
    var userID: UUID?,
    var exp: LocalDateTime,
    var isAdmin: Boolean?,
)
