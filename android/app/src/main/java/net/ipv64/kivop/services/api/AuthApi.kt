package net.ipv64.kivop.services.api

import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.FormBody
import okhttp3.Request


//Api for getting a session token
suspend fun getToken(email: String, password: String): String = withContext(Dispatchers.IO) {
  val path = "auth/login"


  val formBody = FormBody.Builder()
    .add("email", email)
    .add("password", password)
    .build()

  val request = Request.Builder().url(BASE_URL + path).post(formBody).build()

  try {
    okHttpClient.newCall(request).execute().use { response ->
      if (!response.isSuccessful) {
        println("Unexpected code: $response")
        return@withContext ""
      } else {
        val responseBody = response.body?.string()
        val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
        val token = jsonResponse.get("token")?.asString
        if (token != null) {
          return@withContext token
        } else {
          println("Token not found in response")
          return@withContext ""
        }
      }
    }
  } catch (e: Exception) {
    Log.e("token", "Fehler beim Abrufen des Tokens", e)
  }
  return@withContext ""
}

//api call for validating the session token
suspend fun getValidateToken(token: String): Boolean = withContext(Dispatchers.IO) {
  val path = "auth/token-verify"

  val request =
    Request.Builder().url(BASE_URL + path).get()
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


