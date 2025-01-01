package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.time.LocalDateTime
import java.util.UUID

data class UserProfileDTO(
    var uid: UUID?,
    var email: String?,
    var name: String?,
    var profileImage: ByteArray?,
    var isAdmin: Boolean?,
    var isActive: Boolean?,
    var createdAt: LocalDateTime?,
)
