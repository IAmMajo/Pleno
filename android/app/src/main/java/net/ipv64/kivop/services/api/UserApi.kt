package net.ipv64.kivop.services.api

import android.util.Log
import com.google.gson.Gson
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileUpdateDTO
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserRegistrationDTO
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response

suspend fun patchUserProfile(updatedFields: UserProfileUpdateDTO): Response? {
  val path = "users/profile" // Path for the update request

  val token = auth.getSessionToken()

  if (token.isNullOrEmpty()) {
    println("Fehler: Kein Token verfügbar")
    return null
  }

  // Create the request body with the changed fields only
  val jsonBody = Gson().toJson(updatedFields)

  // Create the PATCH request
  val request =
      Request.Builder()
          .url(BASE_URL + path)
          .patch(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
          .addHeader("Authorization", "Bearer $token")
          .build()

  return withContext(Dispatchers.IO) {
    try {
      val response = okHttpClient.newCall(request).execute()
      return@withContext response
    } catch (e: Exception) {
      println("Fehler: ${e.message}")
      null
    }
  }
}

suspend fun postRegister(user: UserRegistrationDTO): Boolean =
    withContext(Dispatchers.IO) {
      val path = "users/register"

      val formBody = Gson().toJson(user)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .post(formBody.toRequestBody("application/json".toMediaTypeOrNull()))
              .build()

      try {
        okHttpClient.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            Log.e("Registration", "Unexpected code: $response")
            return@withContext false
          } else {
            return@withContext true
          }
        }
      } catch (e: Exception) {
        Log.e("Registration", "Fehler bei der Registrierung", e)
      }
      return@withContext false
    }

suspend fun postResendEmail(email: String): Boolean =
    withContext(Dispatchers.IO) {
      val path = "users/email/resend/$email"

      val request = Request.Builder().url(BASE_URL + path).put("".toRequestBody(null)).build()

      try {
        okHttpClient.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            Log.e("Registration", "Unexpected code: $response")
            return@withContext false
          } else {
            return@withContext true
          }
        }
      } catch (e: Exception) {
        Log.e("Registration", "Fehler bei der Registrierung", e)
      }
      return@withContext false
    }
