package com.example.kivopandriod.services.api

import android.content.Context
import com.example.kivopandriod.moduls.MeetingData
import com.google.gson.Gson
import com.google.gson.JsonArray
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter

class MeetingsApi(context: Context) {
    //TODO: Get Meetings
    //TODO: Get Meeting by id
    //TODO: Get Meetings locations
    //TODO: Get Meeting location by id
}

//todo: fix this
suspend fun meetingsList(context: Context): List<MeetingData> = withContext(Dispatchers.IO) {
    val auth = AuthApi(context)
    val url = "https://kivop.ipv64.net/meetings"
    val client = OkHttpClient()
    val token = auth.getToken()

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
                    val id = meeting.get("id").asString

                    // Datum und Uhrzeit aus start extrahieren
                    val zonedDateTime = ZonedDateTime.parse(start, DateTimeFormatter.ISO_ZONED_DATE_TIME)
                    val date = zonedDateTime.toLocalDate()
                    val time = zonedDateTime.toLocalTime()

                    MeetingData(name, date, time,id)
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
