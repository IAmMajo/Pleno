package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class ResetPasswordDTO (
    var email : String?,
    var resetCode : String?,
    var newPassword : String?,
)
