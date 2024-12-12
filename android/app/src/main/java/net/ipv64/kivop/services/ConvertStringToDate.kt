package com.example.kivopandriod.services

import android.annotation.SuppressLint
import java.text.SimpleDateFormat
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Date

@SuppressLint("SimpleDateFormat")
fun stringToDate(dateString: String): Date? {
    val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'")
    format.timeZone = java.util.TimeZone.getTimeZone("UTC")

    return dateString.let { format.parse(it) }
}

fun stringToLocalDate(dateString: String?): LocalDate {
    val trimmedDate = dateString?.substringBefore('T')
    val formatter  = DateTimeFormatter.ofPattern("yyyy-MM-dd")

    return LocalDate.parse(trimmedDate,formatter)
}