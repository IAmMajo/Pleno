package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UserEmailVerificationDTO (
    var uid : UUID?,
    var name : String?,
    var isActive : Boolean?,
    var emailStatus : VerificationStatus?,
    var createdAt : LocalDateTime?,
)
enum class VerificationStatus {
    failed,
    pending,
    verified,
}
