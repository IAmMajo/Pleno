package net.ipv64.kivop.dtos.NotificationsServiceDTOs

import java.util.UUID

import java.time.LocalDateTime

data class SendEmailDTO (
    var receiver : String,
    var subject : String,
    var message : String?,
    var template : String?,
    var templateData : Map<String, String>?
)
