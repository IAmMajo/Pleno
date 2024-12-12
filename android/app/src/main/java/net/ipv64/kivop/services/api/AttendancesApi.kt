// todo: delete this file
package net.ipv64.kivop.services.api

import android.content.Context
import com.google.gson.Gson
import com.google.gson.JsonArray
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request

// Datenmodell für die Antwort
data class ResponseData(
    val name: String, // Name der Person
    val status: Int // Status (z. B. "accepted")
)

suspend fun responseList(id: String, context: Context): List<ResponseData> =
    withContext(Dispatchers.IO) {
      val auth = AuthApi(context)
      val url = "https://kivop.ipv64.net/meetings/$id/attendances"
      val client = OkHttpClient()
      val token = auth.getToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<ResponseData>()
      }

      val request =
          Request.Builder().url(url).addHeader("Authorization", "Bearer $token").get().build()

      try {
        val response = client.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            // JSON-Antwort parsen
            val attendancesArray = Gson().fromJson(responseBody, JsonArray::class.java)
            return@withContext attendancesArray.map { element ->
              val attendance = element.asJsonObject
              val identity = attendance.getAsJsonObject("identity")
              val name = identity.get("name").asString
              val status = attendance.get("status")?.asString // Kann null sein
              val status_in =
                  when (status) {
                    "accepted" -> 1
                    "absent" -> 2
                    else -> 0
                  }
              ResponseData(name, status_in) // Relevante Daten extrahieren
            }
          } else {
            println("Fehler: Leere Antwort erhalten.")
            emptyList<ResponseData>()
          }
        } else {
          println("Fehler bei der Anfrage: ${response.code} - ${response.message}")
          emptyList<ResponseData>()
        }
      } catch (e: Exception) {
        println("Fehler: ${e.message}")
        emptyList<ResponseData>()
      }
    }
