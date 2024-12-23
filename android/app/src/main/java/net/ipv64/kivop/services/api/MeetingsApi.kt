package net.ipv64.kivop.services.api

import android.content.Context
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetLocationDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth

import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request

suspend fun getMeetings(context: Context): List<GetMeetingDTO> =
    withContext(Dispatchers.IO) {
      val auth = AuthController(context)
      val path = "meetings"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetMeetingDTO>()
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val meetingsArray = Gson().fromJson(responseBody, JsonArray::class.java)
            meetingsArray.map { element ->
              val meeting = element.asJsonObject
              val id = meeting.get("id").asString.let { UUID.fromString(it) }
              val name = meeting.get("name").asString
              val description = meeting.get("description").asString
              val status = meeting.get("status").asString.let { MeetingStatus.valueOf(it) }
              val start = meeting.get("start").asString.let { stringToLocalDateTime(it) }
              val duration = meeting.get("duration")?.asInt?.toUShort()
              val location =
                  meeting.get("location")?.asJsonObject?.let { location ->
                    GetLocationDTO(
                        id = location.get("id").asString.let { UUID.fromString(it) },
                        name = location.get("name").asString,
                        street = location.get("street").asString,
                        number = location.get("number").asString,
                        letter = location.get("letter").asString,
                        postalCode = location.get("postalCode")?.asString,
                        place = location.get("place")?.asString,
                    )
                  }
              val chair =
                  meeting.get("chair")?.asJsonObject?.let { chair ->
                    GetIdentityDTO(
                        chair.get("id").asString.let { UUID.fromString(it) },
                        chair.get("name").asString)
                  }
              val code = meeting.get("code")?.asString
              val myAttendanceStatus =
                  meeting.get("myAttendanceStatus")?.asString?.let { AttendanceStatus.valueOf(it) }

              GetMeetingDTO(
                  id,
                  name,
                  description,
                  status,
                  start,
                  duration,
                  location,
                  chair,
                  code,
                  myAttendanceStatus)
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

suspend fun getMeetingByID(id: String): GetMeetingDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/$id"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val meeting = Gson().fromJson(responseBody, JsonObject::class.java)
            val meetingID = meeting.get("id").asString.let { UUID.fromString(it) }
            val name = meeting.get("name").asString
            val description = meeting.get("description").asString
            val status = meeting.get("status").asString.let { MeetingStatus.valueOf(it) }
            val start = meeting.get("start").asString.let { stringToLocalDateTime(it) }
            val duration = meeting.get("duration")?.asInt?.toUShort()
            val location =
                meeting.get("location")?.asJsonObject?.let { location ->
                  GetLocationDTO(
                      location.get("id").asString.let { UUID.fromString(it) },
                      location.get("name").asString,
                      location.get("street").asString,
                      location.get("number").asString,
                      location.get("letter").asString,
                      location.get("postalCode")?.asString,
                      location.get("place")?.asString,
                  )
                }
            val chair =
                meeting.get("chair")?.asJsonObject?.let { chair ->
                  GetIdentityDTO(
                      chair.get("id").asString.let { UUID.fromString(it) },
                      chair.get("name").asString)
                }
            val code = meeting.get("code")?.asString
            val myAttendanceStatus =
                meeting.get("myAttendanceStatus")?.asString?.let { AttendanceStatus.valueOf(it) }

            GetMeetingDTO(
                meetingID,
                name,
                description,
                status,
                start,
                duration,
                location,
                chair,
                code,
                myAttendanceStatus)
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

suspend fun getLocations(context: Context): List<GetLocationDTO> =
    withContext(Dispatchers.IO) {
      val path = "meetings/locations"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetLocationDTO>()
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val locationArray = Gson().fromJson(responseBody, JsonArray::class.java)
            locationArray.map { element ->
              val location = element.asJsonObject
              val id = location.get("id").asString.let { UUID.fromString(it) }
              val name = location.get("name").asString
              val street = location.get("street").asString
              val number = location.get("number").asString
              val letter = location.get("letter").asString
              val postalCode = location.get("postalCode")?.asString
              val place = location.get("place")?.asString

              GetLocationDTO(id, name, street, number, letter, postalCode, place)
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

suspend fun getLocationById(id: String): GetLocationDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/locations/$id"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val location = Gson().fromJson(responseBody, JsonObject::class.java)
            val locationID = location.get("id").asString.let { UUID.fromString(it) }
            val name = location.get("name").asString
            val street = location.get("street").asString
            val number = location.get("number").asString
            val letter = location.get("letter").asString
            val postalCode = location.get("postalCode").asString
            val place = location.get("place").asString

            GetLocationDTO(locationID, name, street, number, letter, postalCode, place)
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
