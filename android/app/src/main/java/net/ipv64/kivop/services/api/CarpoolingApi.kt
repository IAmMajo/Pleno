package net.ipv64.kivop.services.api

import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.models.GetSpecialRideDTO
import net.ipv64.kivop.models.GetSpecialRideDetailDTO
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request
import java.util.UUID

suspend fun getCarpoolingListApi(): List<GetSpecialRideDTO> =
  withContext(Dispatchers.IO) {
    val path = "specialrides"

    val token = auth.getSessionToken()

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
            val starts = meeting.get("starts").asString.let { stringToLocalDateTime(it) }
            val ends = meeting.get("ends").asString.let { stringToLocalDateTime(it) }
            val emptySeats = meeting.get("emptySeats").asInt
            val allocatedSeats = meeting.get("allocatedSeats").asInt
            val isSelfDriver = meeting.get("isSelfDriver").asBoolean
            val isSelfAccepted = meeting.get("isSelfAccepted").asBoolean
            
            GetSpecialRideDTO(
              id,
              name,
              starts,
              ends,
              emptySeats,
              allocatedSeats,
              isSelfDriver,
              isSelfAccepted)
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

suspend fun getCarpoolApi(id: String): GetSpecialRideDetailDTO? =
  withContext(Dispatchers.IO) {
    val path = "specialrides/$id"
    val token = auth.getSessionToken()

    val request = Request.Builder()
      .url(BASE_URL + path)
      .addHeader("Authorization", "Bearer $token")
      .get()
      .build()

    return@withContext try {
      val response = okHttpClient.newCall(request).execute()
      if (response.isSuccessful) {
        val responseBody = response.body?.string()
        if (responseBody != null) {
          val jsonObject = Gson().fromJson(responseBody, JsonObject::class.java)
          
          GetSpecialRideDetailDTO(
            id = jsonObject.get("id").asString.let { UUID.fromString(it) },
            name = jsonObject.get("name").asString,
            starts = jsonObject.get("starts").asString.let { stringToLocalDateTime(it) },
            ends = jsonObject.get("ends").asString.let { stringToLocalDateTime(it) },
            emptySeats = jsonObject.get("emptySeats").asInt,
            destinationLongitude = jsonObject.get("destinationLongitude").asDouble,
            destinationLatitude = jsonObject.get("destinationLatitude").asDouble,
            startLongitude = jsonObject.get("startLongitude").asDouble,
            startLatitude = jsonObject.get("startLatitude").asDouble,
            driverName = jsonObject.get("driverName").asString,
            isSelfDriver = jsonObject.get("isSelfDriver").asBoolean,
            description = jsonObject.get("description").asString,
            riders = jsonObject.getAsJsonArray("riders")?.map { it.asString }
          )
        } else {
          println("Error: Empty response body.")
          null
        }
      } else {
        println("Request failed: ${response.message}")
        null
      }
    } catch (e: Exception) {
      println("Error: ${e.message}")
      null
    }
  }