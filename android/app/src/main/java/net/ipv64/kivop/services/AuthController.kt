package net.ipv64.kivop.services

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import net.ipv64.kivop.MainActivity
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserLoginDTO
import net.ipv64.kivop.services.api.getToken
import net.ipv64.kivop.services.api.getValidateToken


class AuthController(private val context: Context) {
  companion object {
    private const val PREF_SESSION_TOKEN = "session_token"
    private const val PREF_USER_EMAIL = "user_email"
    private const val PREF_USER_PASSWORD = "user_password"

  }
  
  suspend fun login(email: String, password: String):Boolean {
    val token = getToken(email, password)
    if (token != ""){
      saveSessionToken(token)
      saveCredentials(email, password)
      return true
    }
    return false
  }

  fun logout() {
    val sharedPreferences = getEncryptedSharedPreferences(context)

    sharedPreferences.edit().remove(PREF_SESSION_TOKEN).apply()
    sharedPreferences.edit().remove(PREF_USER_EMAIL).apply()
    sharedPreferences.edit().remove(PREF_USER_PASSWORD).apply()
  }

  suspend fun validateToken(token: String): Boolean {
    return getValidateToken(token)
  }
  
  suspend fun refreshSession() {
    val credentials = getCredentials()
    login(credentials.email!!, credentials.password!!)
  }
  
  suspend fun getSessionToken(): String {
    val sharedPreferences = getEncryptedSharedPreferences(context)

    var sessionToken = sharedPreferences.getString(PREF_SESSION_TOKEN, "")
    if (!sessionToken.isNullOrEmpty()) {
      try {
          if (!validateToken(sessionToken)) {
            refreshSession()
            sessionToken = sharedPreferences.getString(PREF_SESSION_TOKEN, "")
          }
      } catch (e: Exception) {
        logout() // Log out the user if token refresh fails
        return ""
      }
    }
    
    return sessionToken ?: ""
  }
  
  private fun saveSessionToken(token: String) {
    val sharedPreferences = getEncryptedSharedPreferences(context)
    
    sharedPreferences.edit().putString(PREF_SESSION_TOKEN, token).apply()
  }

  private fun saveCredentials(email: String, password: String) {
    val sharedPreferences = getEncryptedSharedPreferences(context)
    
    sharedPreferences.edit().putString(PREF_USER_EMAIL, email).apply()
    sharedPreferences.edit().putString(PREF_USER_PASSWORD, password).apply()
  }
  private fun getCredentials(): UserLoginDTO {
    val sharedPreferences = getEncryptedSharedPreferences(context)

    val email = sharedPreferences.getString(PREF_USER_EMAIL, "")
    val password = sharedPreferences.getString(PREF_USER_PASSWORD, "")
    if (email != null && password != null) {
      return UserLoginDTO(email, password)
    }
    return UserLoginDTO("", "")
  }
  
  private fun getEncryptedSharedPreferences(context: Context): SharedPreferences {
    // Create or retrieve a master key
    val masterKey = MasterKey.Builder(context, MasterKey.DEFAULT_MASTER_KEY_ALIAS)
      .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
      .build()

    // Initialize EncryptedSharedPreferences
    return EncryptedSharedPreferences.create(
      context,
      "secure_prefs",
      masterKey,
      EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV, // Key encryption scheme
      EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM // Value encryption scheme
    )
  }

  suspend fun isLoggedIn(): Boolean {
    val userLoginDTO = getCredentials()
    val token = getSessionToken()
    if (userLoginDTO.email?.isNotEmpty() == true && userLoginDTO.password?.isNotEmpty() == true) {
      if (validateToken(token)) {
        return true
      } else{
        try {
          refreshSession()
          return true
        } catch (e: Exception){
          logout()
          return false
        }
      }
    }
    return false
  }
}