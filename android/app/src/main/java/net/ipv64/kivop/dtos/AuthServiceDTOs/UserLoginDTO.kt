package net.ipv64.kivop.dtos.AuthServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class UserLoginDTO (
    var email : String?,
    var password : String?,
)
