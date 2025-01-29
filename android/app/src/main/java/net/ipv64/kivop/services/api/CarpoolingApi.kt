package net.ipv64.kivop.services.api

import android.util.Log
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.time.format.DateTimeFormatter
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.RideServiceDTOs.CreateSpecialRideDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.GetRiderDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.GetSpecialRideDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.GetSpecialRideDetailDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.UsersRideState
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

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
              val id = meeting.get("id")?.asString.let { UUID.fromString(it) }
              val name = meeting.get("name").asString
              val starts = meeting.get("starts").asString.let { stringToLocalDateTime(it) }
              val ends = meeting.get("ends").asString.let { stringToLocalDateTime(it) }
              val emptySeats = meeting.get("emptySeats").asInt.toUByte()
              val allocatedSeats = meeting.get("allocatedSeats").asInt.toUByte()
              val myState = meeting.get("myState").asString.let { UsersRideState.valueOf(it) }
              val openRequests = meeting.get("openRequests")?.asInt

              GetSpecialRideDTO(
                  id, name, starts, ends, emptySeats, allocatedSeats, myState, openRequests)
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
            val jsonObject = Gson().fromJson(responseBody, JsonObject::class.java)
            val ridersList = jsonObject.get("riders").asJsonArray
            GetSpecialRideDetailDTO(
                id = jsonObject.get("id").asString.let { UUID.fromString(it) },
                driverName = jsonObject.get("driverName").asString,
                driverID = jsonObject.get("id").asString.let { UUID.fromString(it) },
                isSelfDriver = jsonObject.get("isSelfDriver").asBoolean,
                name = jsonObject.get("name").asString,
                description = jsonObject.get("description")?.asString,
                vehicleDescription = jsonObject.get("vehicleDescription")?.asString,
                starts = jsonObject.get("starts").asString.let { stringToLocalDateTime(it) },
                ends = jsonObject.get("ends").asString.let { stringToLocalDateTime(it) },
                startLatitude = jsonObject.get("startLatitude").asFloat,
                startLongitude = jsonObject.get("startLongitude").asFloat,
                destinationLatitude = jsonObject.get("destinationLatitude").asFloat,
                destinationLongitude = jsonObject.get("destinationLongitude").asFloat,
                emptySeats = jsonObject.get("emptySeats").asInt.toUByte(),
                riders =
                    ridersList.map { rider ->
                      val riderObject = rider.asJsonObject
                      GetRiderDTO(
                          id = riderObject.get("id").asString.let { UUID.fromString(it) },
                          userID = riderObject.get("userID").asString.let { UUID.fromString(it) },
                          username = riderObject.get("username").asString,
                          latitude = riderObject.get("latitude").asFloat,
                          longitude = riderObject.get("longitude").asFloat,
                          itsMe = riderObject.get("itsMe").asBoolean,
                          accepted = riderObject.get("accepted").asBoolean)
                    },
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

suspend fun postCarpoolApi(createSpecialRideDTO: CreateSpecialRideDTO): Boolean =
    withContext(Dispatchers.IO) {
      val path = "specialrides"
      val token = auth.getSessionToken()

      val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME
      val jsonMap =
          mutableMapOf<String, Any>(
              "name" to createSpecialRideDTO.name,
              "starts" to createSpecialRideDTO.starts.format(formatter) + "Z",
              "ends" to createSpecialRideDTO.ends.format(formatter) + "Z",
              "startLatitude" to createSpecialRideDTO.startLatitude,
              "startLongitude" to createSpecialRideDTO.startLongitude,
              "destinationLatitude" to createSpecialRideDTO.destinationLatitude,
              "destinationLongitude" to createSpecialRideDTO.destinationLongitude,
              "emptySeats" to createSpecialRideDTO.emptySeats.toInt())
      createSpecialRideDTO.description
          ?.takeIf { it.isNotBlank() }
          ?.let { jsonMap["description"] = it }
      createSpecialRideDTO.vehicleDescription
          ?.takeIf { it.isNotBlank() }
          ?.let { jsonMap["vehicleDescription"] = it }

      val jsonBody = Gson().toJson(jsonMap)
      
      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .post(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        response.isSuccessful
      } catch (e: Exception) {
        println("Error: ${e.message}")
        false
      }
    }

suspend fun postRequestSpecialRideApi(
    specialRideId: String,
    position: Pair<Double, Double>
): Boolean =
    withContext(Dispatchers.IO) {
      val path = "specialrides/$specialRideId/requests"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }
      val jsonMap =
          mutableMapOf<String, Any>(
              "latitude" to position.first,
              "longitude" to position.second,
          )

      val jsonBody = Gson().toJson(jsonMap)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .post(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
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

suspend fun patchAcceptRiderRequest(riderId: String, accepted: Boolean): Boolean =
    withContext(Dispatchers.IO) {
      val path = "specialrides/requests/$riderId"
      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }

      val jsonBody = Gson().toJson(mapOf("accepted" to accepted))

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .patch(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
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
        Log.e("patch", "Fehler: ${e.message}")
        false
      }
    }

suspend fun deleteRiderRequest(riderId: String): Boolean =
    withContext(Dispatchers.IO) {
      val path = "specialrides/requests/$riderId"
      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .delete()
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
        Log.e("delete", "Fehler: ${e.message}")
        false
      }
    }
