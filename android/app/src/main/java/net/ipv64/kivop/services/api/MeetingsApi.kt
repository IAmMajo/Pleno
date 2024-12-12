package net.ipv64.kivop.services.api

import android.content.Context
import android.util.Log
import com.example.kivopandriod.moduls.Location
import com.example.kivopandriod.moduls.SitzungsCardData
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonElement
import com.google.gson.JsonObject
import java.time.ZonedDateTime
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.moduls.AttendancesListsData
import okhttp3.OkHttpClient
import okhttp3.Request

class MeetingsApi(context: Context) {
  // TODO: Get Meetings
  // TODO: Get Meeting by id
  // TODO: Get Meetings locations
  // TODO: Get Meeting location by id
}

// todo: fix this
suspend fun meetingsList(context: Context): List<AttendancesListsData> =
    withContext(Dispatchers.IO) {
      val auth = AuthApi(context)
      val url = "https://kivop.ipv64.net/meetings"
      val client = OkHttpClient()
      val token = auth.getToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<AttendancesListsData>()
      }

      val request =
          Request.Builder().url(url).addHeader("Authorization", "Bearer $token").get().build()

      return@withContext try {
        val response = client.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val meetingsArray = Gson().fromJson(responseBody, JsonArray::class.java)
            meetingsArray.map { element ->
              val meeting = element.asJsonObject
              val title = meeting.get("name").asString
              val start = meeting.get("start").asString
              val id = meeting.get("id").asString

              // Datum und Uhrzeit aus start extrahieren
              val zonedDateTime = ZonedDateTime.parse(start, DateTimeFormatter.ISO_ZONED_DATE_TIME)
              val date = zonedDateTime.toLocalDate()
              val time = zonedDateTime.toLocalTime()

              AttendancesListsData(title, date, time, id = id)
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

suspend fun getMeetingsByID(context: Context, id: String): SitzungsCardData? =
  withContext(Dispatchers.IO) {
    val auth = AuthApi(context)
    val url = "https://kivop.ipv64.net/meetings/$id"
    val client = OkHttpClient()
    val token = auth.getToken()

    if (token.isNullOrEmpty()) {
      println("Fehler: Kein Token verfügbar")
      return@withContext null
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
          val gson = Gson()
          val meeting = gson.fromJson(responseBody, JsonObject::class.java)

          // Extrahiere Daten aus dem JSON-Objekt
          val meetingTitle = meeting.get("name").asString
          val start = meeting.get("start").asString
          val duration = meeting.get("duration").asInt
          val locationJson = meeting.getAsJsonObject("location")

          // Konvertiere `location` in die `Location`-Klasse
          val location = Location(
            letter = locationJson.get("letter")?.asString ?: "",
            street = locationJson.get("street")?.asString ?: "",
            name = locationJson.get("name").asString,
            locationId = locationJson.get("id").asString,
            number = locationJson.get("number")?.asString ?: "",
            postalCode = locationJson.get("postalCode")?.asString ?: "",
            place = locationJson.get("place")?.asString ?: ""
          )

          // Datum und Uhrzeit aus `start` extrahieren
          val zonedDateTime = ZonedDateTime.parse(start, DateTimeFormatter.ISO_ZONED_DATE_TIME)
          val date = zonedDateTime.toLocalDate()
          val time = zonedDateTime.toLocalTime()
          
          
          Log.d("Test-log", "Datum: $date, Uhrzeit: $time,Location: $location")
          
          
          // Erstelle und gib das `SitzungsCardData`-Objekt zurück
          return@withContext SitzungsCardData(
            meetingTitle = meetingTitle,
            date = date,
            time = time,
            meetingId = id,
            duration = duration,
            location = location
          )
        } else {
          println("Fehler: Leere Antwort erhalten.")
          null
        }
      } else {
        println("Fehler bei der Anfrage: ${response.message}")
        null
      }
    } catch (e: Exception) {
      println("Fehler: ${e.message}")
      null
    }
  }
