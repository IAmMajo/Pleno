package com.example.kivopandriod.services.api

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.FormBody
import okhttp3.OkHttpClient
import okhttp3.Request

class AuthApi(private val context: Context) {
  suspend fun login(email: String, password: String) {
    withContext(Dispatchers.IO) {
      val url = "https://kivop.ipv64.net/auth/login"
      val client = OkHttpClient()

      val formBody = FormBody.Builder().add("email", email).add("password", password).build()

      val request = Request.Builder().url(url).post(formBody).build()
      try {
        client.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            println("Unexpected code: $response")
          } else {
            val responseBody = response.body?.string()
            val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
            val token = jsonResponse.get("token")?.asString
            if (token != null) {
              Log.e("token", token)
              storeToken(token)
            }
          }
        }
      } catch (e: Exception) {
        Log.e("token", "Fehler beim Login", e)
      }
    }
  }

  fun register(email: String, password: String) {
    // TODO: Registrierung
  }

  fun logout() {
    val sharedPreferences = context.getSharedPreferences("auth", Context.MODE_PRIVATE)
    with(sharedPreferences.edit()) {
      remove("auth_token")
      apply()
    }
  }

  private fun storeToken(token: String) {
    // TODO: Token en-/decrypten: val encryptedToken = encryptToken(token)

    val sharedPreferences = context.getSharedPreferences("auth", Context.MODE_PRIVATE)
    with(sharedPreferences.edit()) {
      putString("auth_token", token)
      apply()
    }
  }

  suspend fun getToken(): String? {
    if (isLoggedIn()) {
      val sharedPreferences = context.getSharedPreferences("auth", Context.MODE_PRIVATE)
      val token = sharedPreferences.getString("auth_token", null)
      return token // todo: Token en-/decrypten: encryptedToken?.let { decryptToken(it) }
    } else {
      return null
    }
  }

  suspend fun isLoggedIn(): Boolean {
    val sharedPreferences = context.getSharedPreferences("auth", Context.MODE_PRIVATE)
    val token = sharedPreferences.getString("auth_token", null)
    if (token == null) {
      return false
    } else {
      return validateToken(token)
    }
  }

  private suspend fun validateToken(token: String): Boolean {
    return withContext(Dispatchers.IO) {
      val url = "https://kivop.ipv64.net/auth/token-verify"
      val client = OkHttpClient()

      val request =
          Request.Builder().url(url).get().addHeader("Authorization", "Bearer $token").build()

      try {
        client.newCall(request).execute().use { response ->
          if (!response.isSuccessful) {
            Log.e("token", "Token-Validierung fehlgeschlagen")
            return@withContext false
          } else if (response.code == 200) {
            Log.i("token", "Token-Validierung erfolgreich")
            return@withContext true
          }
        }
      } catch (e: Exception) {
        Log.e("token", "Fehler beim Token-Validieren", e)
      }
      return@withContext false
    }
  }
  // TODO: Token en-/decrypten
  //    private fun encryptToken(token: String): String {
  //
  //    }
  //
  //    private fun decryptToken(encryptedToken: String): String {
  //
  //    }
}
