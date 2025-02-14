package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID
import java.time.LocalDateTime

data class UserRegistrationDTO (
    var name : String?,
    var email : String?,
    var password : String?,
    var profileImage : String?,
)
