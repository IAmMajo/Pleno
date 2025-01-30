package net.ipv64.kivop.services.api

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetRecordDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.RecordStatus
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request

// ToDO LIste
suspend fun getProtocolsApi(id: String): List<GetRecordDTO> =
    withContext(Dispatchers.IO) {
      val path = "meetings/$id/records"
      val token = auth.getSessionToken()

      Log.e("Protokol-IN", token ?: "Kein Token verfügbar")

      if (token.isNullOrEmpty()) {
        Log.e("Fehler", "Kein Token verfügbar")
        return@withContext emptyList<GetRecordDTO>()
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
          if (responseBody.isNullOrEmpty()) {
            Log.e("Fehler", "Leere Antwort erhalten.")
            emptyList()
          } else {
            // JSON-Parsing
            val protocolsArray = Gson().fromJson(responseBody, JsonArray::class.java)
            protocolsArray.map { element ->
              val protocol = element.asJsonObject
              val meetingId = UUID.fromString(protocol.get("meetingId").asString)
              val lang = protocol.get("lang").asString
              val content = protocol.get("content").asString
              val attendancesAppendix = protocol.get("attendancesAppendix").asString
              val votingResultsAppendix = protocol.get("votingResultsAppendix")?.asString
              val status = RecordStatus.valueOf(protocol.get("status").asString)
              val identity =
                  protocol.get("identity").asJsonObject.let { chair ->
                    GetIdentityDTO(
                        UUID.fromString(chair.get("id").asString), chair.get("name").asString)
                  }
              val iAmTheRecorder = protocol.get("iAmTheRecorder").asBoolean
              Log.d("Protokoll-in-3", "Protokoll erhalten: $meetingId")

              GetRecordDTO(
                  meetingId,
                  lang,
                  identity,
                  status,
                  content,
                  attendancesAppendix,
                  votingResultsAppendix,
                  iAmTheRecorder)
            }
          }
        } else {
          Log.e("Fehler bei der Anfrage", response.message)
          emptyList()
        }
      } catch (e: Exception) {
        Log.e("Fehler", "${e.message}", e)
        emptyList()
      }
    }

suspend fun getProtocolApi(id: String, lang: String): GetRecordDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/$id/records/$lang"

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
            val protocol = Gson().fromJson(responseBody, JsonObject::class.java)
            val meetingId = protocol.get("meetingId").asString.let { UUID.fromString(it) }
            val lang = protocol.get("lang").asString
            val content = protocol.get("content").asString
            val attendancesAppendix = protocol.get("attendancesAppendix").asString
            val votingResultsAppendix = protocol.get("votingResultsAppendix")?.asString
            val status = protocol.get("status").asString.let { RecordStatus.valueOf(it) }
            val identity =
                protocol.get("identity").asJsonObject.let { chair ->
                  GetIdentityDTO(
                      chair.get("id").asString.let { UUID.fromString(it) },
                      chair.get("name").asString)
                }
            val iAmTheRecorder = protocol.get("iAmTheRecorder").asBoolean
            Log.i(
                "Protokoll",
                "Protokoll erhalten: $meetingId , $lang , $identity , $status , $content , $attendancesAppendix , $votingResultsAppendix")

            GetRecordDTO(
                meetingId,
                lang,
                identity,
                status,
                content,
                attendancesAppendix,
                votingResultsAppendix,
                iAmTheRecorder)
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
