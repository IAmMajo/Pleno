package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UserProfileUpdateDTO (
    var name : String?,
    var profileImage : String?,
)
