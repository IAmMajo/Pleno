package net.ipv64.kivop.services.api

import android.util.Log
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.ResponsibleUsersDTO
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.util.UUID

suspend fun getPostersApi(): List<PosterResponseDTO> =
  withContext(Dispatchers.IO) {
    val path = "posters"

    val token = auth.getSessionToken()

    if (token.isNullOrEmpty()) {
      println("Fehler: Kein Token verfügbar")
      return@withContext emptyList<PosterResponseDTO>()
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
          val posterArray = Gson().fromJson(responseBody, JsonArray::class.java)
          posterArray.map { element ->
            val poster = element.asJsonObject
            val id = poster.get("id").asString.let { UUID.fromString(it) }
            val name = poster.get("name").asString
            val description = poster.get("description").asString
            val image = poster.get("image").asString
            PosterResponseDTO(
              id,
              name,
              description,
              image
              )
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

suspend fun getPosterByIDApi(id: String): PosterResponseDTO? =
  withContext(Dispatchers.IO) {
    val path = "posters/$id"

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
          val poster = Gson().fromJson(responseBody, JsonObject::class.java)
          val id = poster.get("id").asString.let { UUID.fromString(it) }
          val name = poster.get("name").asString
          val description = poster.get("description").asString
          val image = poster.get("image").asString

          PosterResponseDTO(
            id,
            name,
            description,
            image
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

suspend fun getPosterSummaryByIDApi(id: String): PosterSummaryResponseDTO? =
  withContext(Dispatchers.IO) {
    val path = "posters/$id/summary"

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
          val poster = Gson().fromJson(responseBody, JsonObject::class.java)
          val hangs = poster.get("hangs").asInt
          val toHang = poster.get("toHang").asInt
          val overdue = poster.get("overdue").asInt
          val takenDown = poster.get("takenDown").asInt
          val damaged = poster.get("damaged").asInt
          val nextTakeDown = poster.get("nextTakeDown")?.asString?.let { stringToLocalDateTime(it) }
          
          PosterSummaryResponseDTO(
            hangs,
            toHang,
            overdue,
            takenDown,
            damaged,
            nextTakeDown
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

suspend fun getPosterLocationsByIDApi(posterID: String): List<PosterPositionResponseDTO> =
  withContext(Dispatchers.IO) {
    val path = "posters/$posterID/positions"

    val token = auth.getSessionToken()

    if (token.isNullOrEmpty()) {
      println("Fehler: Kein Token verfügbar")
      return@withContext emptyList<PosterPositionResponseDTO>()
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
          val posterPositionArray = Gson().fromJson(responseBody, JsonArray::class.java)
          posterPositionArray.map { element ->
            val posterPosition = element.asJsonObject
            val id = posterPosition.get("id").asString.let { UUID.fromString(it) }
            val posterId = posterPosition.get("posterId")?.asString?.let { UUID.fromString(it) }
            val latitude = posterPosition.get("latitude").asDouble
            val longitude = posterPosition.get("longitude").asDouble
            val postedBy = posterPosition.get("postedBy")?.asString
            val postedAt = posterPosition.get("postedAt")?.asString?.let { stringToLocalDateTime(it) }
            val expiresAt = posterPosition.get("expiresAt").asString.let { stringToLocalDateTime(it) }
            val removedBy = posterPosition.get("removedBy")?.asString
            val removedAt = posterPosition.get("removedAt")?.asString?.let { stringToLocalDateTime(it) }
            val image = posterPosition.get("image")?.asString
            val responsibleUsersArray = posterPosition.get("responsibleUsers").asJsonArray 
            val responsibleUsers =
              responsibleUsersArray.map { user ->
                val responsibleUsersObject = user.asJsonObject
                  ResponsibleUsersDTO(
                    id = responsibleUsersObject.get("id").asString.let { UUID.fromString(it) },
                    name = responsibleUsersObject.get("name").asString
                  )
              }
            val status = posterPosition.get("status").asString.let { PosterPositionStatus.valueOf(it) }
            
            PosterPositionResponseDTO(
              id,
              posterId,
              latitude,
              longitude,
              postedBy,
              postedAt,
              expiresAt,
              removedBy,
              removedAt,
              image,
              responsibleUsers,
              status,
            )
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

suspend fun getPosterLocationByIDApi(posterId: String, locationId: String): PosterPositionResponseDTO? =
  withContext(Dispatchers.IO) {
    val path = "posters/$posterId/positions/$locationId"

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
          val posterLocation = Gson().fromJson(responseBody, JsonObject::class.java)
          val id = posterLocation.get("id").asString.let { UUID.fromString(it) }
          val posterId = posterLocation.get("posterId")?.asString?.let { UUID.fromString(it) }
          val latitude = posterLocation.get("latitude").asDouble
          val longitude = posterLocation.get("longitude").asDouble
          val postedBy = posterLocation.get("postedBy")?.asString
          val postedAt = posterLocation.get("postedAt")?.asString?.let { stringToLocalDateTime(it) }
          val expiresAt = posterLocation.get("expiresAt").asString.let { stringToLocalDateTime(it) }
          val removedBy = posterLocation.get("removedBy")?.asString
          val removedAt = posterLocation.get("removedAt")?.asString?.let { stringToLocalDateTime(it) }
          val image = posterLocation.get("image")?.asString
          val responsibleUsersArray = posterLocation.get("responsibleUsers").asJsonArray
          val responsibleUsers =
            responsibleUsersArray.map { user ->
              val responsibleUsersObject = user.asJsonObject
              ResponsibleUsersDTO(
                id = responsibleUsersObject.get("id").asString.let { UUID.fromString(it) },
                name = responsibleUsersObject.get("name").asString
              )
            }
          val status = posterLocation.get("status").asString.let { PosterPositionStatus.valueOf(it) }

          PosterPositionResponseDTO(
            id,
            posterId,
            latitude,
            longitude,
            postedBy,
            postedAt,
            expiresAt,
            removedBy,
            removedAt,
            image,
            responsibleUsers,
            status,
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

suspend fun putHangPoster(locationID: String, base64: String): Boolean =
  withContext(Dispatchers.IO) {
    val path = "posters/positions/$locationID/hang"

    val token = auth.getSessionToken()

    if (token.isNullOrEmpty()) {
      println("Fehler: Kein Token verfügbar")
      return@withContext false
    }

    val jsonBody = JSONObject().apply { put("image", base64) }

    val request =
      Request.Builder()
        .url(BASE_URL + path)
        .addHeader("Authorization", "Bearer $token")
        .put(jsonBody.toString().toRequestBody("application/json".toMediaTypeOrNull()))
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

suspend fun putTakeDownPoster(locationID: String, base64: String): Boolean =
  withContext(Dispatchers.IO) {
    val path = "posters/positions/$locationID/take-down"

    val token = auth.getSessionToken()

    if (token.isNullOrEmpty()) {
      println("Fehler: Kein Token verfügbar")
      return@withContext false
    }

    val jsonBody = Gson().toJson(base64)

    val request =
      Request.Builder()
        .url(BASE_URL + path)
        .addHeader("Authorization", "Bearer $token")
        .put(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
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