package com.example.kivopandriod.services

import java.time.LocalDateTime
import java.time.format.DateTimeFormatter

fun stringToLocalDateTime(dateString: String?): LocalDateTime {
  val formatter = DateTimeFormatter.ISO_DATE_TIME
  return LocalDateTime.parse(dateString,formatter)
}
