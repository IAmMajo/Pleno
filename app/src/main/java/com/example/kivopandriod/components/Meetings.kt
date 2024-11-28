package com.example.kivopandriod.components

import Login
import android.os.Build
import androidx.annotation.RequiresApi
import com.google.gson.Gson
import com.google.gson.JsonArray
import kotlinx.coroutines.runBlocking
import okhttp3.OkHttpClient
import okhttp3.Request
import java.time.LocalDate
import java.time.LocalTime
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext


@RequiresApi(Build.VERSION_CODES.O)
fun main() = runBlocking {
    Login(email = "admin@kivop.ipv64.net", password = "admin") // Login aufrufen

    val meetings = meetingsList() // Meetings abrufen

    if (meetings.isEmpty()) {
        println("Keine Meetings gefunden.")
    } else {
        println("Meetings:")
        meetings.forEach { meeting ->
            println("Name: ${meeting.name}, Date: ${meeting.date}, Time: ${meeting.time}")
        }
    }
}



// Datenmodell für ein Meeting
data class MeetingData(
    val name: String,
    val date: LocalDate,
    val time: LocalTime
)

@RequiresApi(Build.VERSION_CODES.O)
suspend fun meetingsList(): List<MeetingData> = withContext(Dispatchers.IO) {
    val url = "https://kivop.ipv64.net/meetings"
    val client = OkHttpClient()
    val token = TokenManager.jwtToken

    if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<MeetingData>()
    }

    val request = Request.Builder()
        .url(url)
        .addHeader("Authorization", "Bearer $token")
        .get()
        .build()

    return@withContext try {
        val response = client.newCall(request).execute()
        if (response.isSuccessful) {
            val responseBody = response.body?.string()
            if (responseBody != null) {
                val meetingsArray = Gson().fromJson(responseBody, JsonArray::class.java)
                meetingsArray.map { element ->
                    val meeting = element.asJsonObject
                    val name = meeting.get("name").asString
                    val start = meeting.get("start").asString

                    // Datum und Uhrzeit aus `start` extrahieren
                    val zonedDateTime = ZonedDateTime.parse(start, DateTimeFormatter.ISO_ZONED_DATE_TIME)
                    val date = zonedDateTime.toLocalDate()
                    val time = zonedDateTime.toLocalTime()

                    MeetingData(name, date, time)
                }
            } else {
                println("Fehler: Leere Antwort erhalten.")
                emptyList()
            }
        } else {
            println("Fehler bei der Anfrage: ${response.message}")
            emptyList()
        }
    } catch (e: Exception) {
        println("Fehler: ${e.message}")
        emptyList()
    }
}
