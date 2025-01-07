package net.ipv64.kivop.services.api

import android.util.Log
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonObject
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.dtos.AuthServiceDTOs.VerificationStatus
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.FormBody
import okhttp3.Request

// Api for getting a session token
suspend fun getToken(email: String, password: String): Pair<String, String> =
    withContext(Dispatchers.IO) {
      val path = "auth/login"
      val formBody = FormBody.Builder().add("email", email).add("password", password).build()

      val request = Request.Builder().url(BASE_URL + path).post(formBody).build()

      try {
        okHttpClient.newCall(request).execute().use { response ->
          val responseBody =
              response.body?.string() ?: return@withContext "" to "Empty response body"

          return@withContext if (response.isSuccessful) {
            // Successful response
            val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
            val token = jsonResponse.get("token")?.asString
            if (token != null) {
              token to "loggedin" // Status for successful login
            } else {
              "" to "Token not found in response"
            }
          } else {
            // Handle error cases
            val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
            val reason = jsonResponse.get("reason")?.asString
            return@withContext when (reason) {
              "This account is inactiv" -> "" to "This account is inactiv"
              "Email not verified" -> "" to "Email not verified"
              else -> "" to "Invalid credentials"
            }
          }
        }
      } catch (e: Exception) {
        Log.e("token", "Error while retrieving the token", e)
        return@withContext "" to "Error occurred: ${e.localizedMessage}"
      }
    }

// api call for validating the session token
suspend fun getValidateToken(token: String): Boolean =
    withContext(Dispatchers.IO) {
      val path = "auth/token-verify"

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .get()
              .addHeader("Authorization", "Bearer $token")
              .build()

      try {
        okHttpClient.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            return@withContext false
          } else if (response.code == 200) {
            return@withContext true
          }
        }
      } catch (e: Exception) {
        Log.e("token", "Fehler beim Token-Validieren", e)
      }
      return@withContext false
    }

suspend fun getUserProfile(): UserProfileDTO? =
    withContext(Dispatchers.IO) {
      val path = "users/profile"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .get()
              .addHeader("Authorization", "Bearer $token")
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val profileObject = Gson().fromJson(responseBody, JsonObject::class.java)
            val uid = profileObject.get("uid")?.asString.let { UUID.fromString(it) }
            val email = profileObject.get("email")?.asString
            val name = profileObject.get("name")?.asString
            val profileImage = profileObject.get("profileImage")?.asString
            val isAdmin = profileObject.get("isAdmin")?.asBoolean
            val isActive = profileObject.get("isActive")?.asBoolean
            val emailVerification =
                profileObject.get("emailVerification")?.asString?.let {
                  VerificationStatus.valueOf(it)
                }
            val createdAt =
                profileObject.get("createdAt")?.asString.let { stringToLocalDateTime(it) }
            UserProfileDTO(
                uid, email, name, profileImage, isAdmin, isActive, emailVerification, createdAt)
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
