package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UserProfileDTO (
    var uid : UUID,
    var email : String,
    var name : String,
    var profileImage : String,
    var isAdmin : Boolean,
    var isActive : Boolean,
    var emailVerification : VerificationStatus,
    var createdAt : LocalDateTime,
    var isNotificationsActive : Boolean,
    var isPushNotificationsActive : Boolean,
)
enum class VerificationStatus {
    failed,
    pending,
    verified,
}
