package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class ChangePasswordDTO (
    var oldPassword : String?,
    var newPassword : String?,
)
