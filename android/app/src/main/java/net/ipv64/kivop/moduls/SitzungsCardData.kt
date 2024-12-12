package com.example.kivopandriod.moduls

import java.time.LocalDate
import java.time.LocalTime

data class Location(
    var name: String,
    var street: String? = null,
    var number: String? = null,
    var letter: String? = null,
    var postalCode: String? = null,
    var place: String? = null,
    var locationId: String?
)

data class SitzungsCardData(
    val meetingTitle: String,
    val date: LocalDate?,
    val time: LocalTime?,
    val meetingId: String,
    val duration: Int,
    val location: Location?
)
