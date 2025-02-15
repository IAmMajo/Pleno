// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.services.api

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonArray
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetAttendanceDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

suspend fun getAttendances(id: String): List<GetAttendanceDTO> =
    withContext(Dispatchers.IO) {
      val path = "meetings/$id/attendances"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetAttendanceDTO>()
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val attendancesArray = Gson().fromJson(responseBody, JsonArray::class.java)
            return@withContext attendancesArray.map { element ->
              val attendance = element.asJsonObject
              val meetingID = attendance.get("meetingId").asString.let { UUID.fromString(it) }
              val identity =
                  attendance.getAsJsonObject("identity").let { identity ->
                    GetIdentityDTO(
                        identity.get("id").asString.let { UUID.fromString(it) },
                        identity.get("name").asString)
                  }
              val status = attendance.get("status")?.asString?.let { AttendanceStatus.valueOf(it) }
              val itsame = attendance.get("itsame").asBoolean
              GetAttendanceDTO(meetingID, identity, status, itsame)
            }
          } else {
            println("Fehler: Leere Antwort erhalten.")
            emptyList()
          }
        } else {
          println("Fehler bei der Anfrage: ${response.code} - ${response.message}")
          emptyList()
        }
      } catch (e: Exception) {
        println("Fehler: ${e.message}")
        emptyList()
      }
    }

suspend fun putPlanAttendance(meetingId: String, status: PlanAttendance): Boolean =
    withContext(Dispatchers.IO) {
      val path = "meetings/$meetingId/plan-attendance/${status.name}"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }

      val emptyBody = ByteArray(0).toRequestBody(null)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .put(emptyBody)
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          true
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          false
        }
      } catch (e: Exception) {
        Log.e("put", "Fehler: ${e.message}")
        false
      }
    }

suspend fun putAttend(meetingId: String, code: String): Boolean =
    withContext(Dispatchers.IO) {
      val path = "meetings/$meetingId/attend/$code"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }

      val emptyBody = ByteArray(0).toRequestBody(null)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .put(emptyBody)
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          true
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          false
        }
      } catch (e: Exception) {
        Log.e("put", "Fehler: ${e.message}")
        false
      }
    }
