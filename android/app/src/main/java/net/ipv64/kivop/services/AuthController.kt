package net.ipv64.kivop.services

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserLoginDTO
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserRegistrationDTO
import net.ipv64.kivop.services.api.getToken
import net.ipv64.kivop.services.api.getValidateToken
import net.ipv64.kivop.services.api.postRegister
import net.ipv64.kivop.services.api.postResendEmail

class AuthController(private val context: Context) {
  companion object {
    private const val PREF_SESSION_TOKEN = "session_token"
    private const val PREF_USER_EMAIL = "user_email"
    private const val PREF_USER_PASSWORD = "user_password"
  }

  private val appContext = context.applicationContext

  suspend fun login(email: String, password: String): String? {
    val (token, status) = getToken(email, password)
    return when (status) {
      "loggedin" -> {
        // Save session and credentials if login is successful
        saveSessionToken(token)
        saveCredentials(email, password)
        "Successful Login!"
      }
      "This account is inactiv" -> {
        saveSessionToken(token)
        saveCredentials(email, password)
        "This account is inactiv"
      }
      "Email not verified" -> {
        saveSessionToken(token)
        saveCredentials(email, password)
        "Email not verified"
      }
      "Invalid credentials" -> "Invalid credentials"
      else -> "Unexpected error: $status"
    }
  }
  
  suspend fun register(user: UserRegistrationDTO): Boolean {
    if(postRegister(user)){
      saveCredentials(user.email!!, user.password!!)
      return true
    }
    return false
  }
  
  suspend fun resendEmail() {
    val credentials = getCredentials()
    postResendEmail(credentials.email!!)
  }
  
  fun logout() {
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().remove(PREF_SESSION_TOKEN).apply()
    sharedPreferences.edit().remove(PREF_USER_EMAIL).apply()
    sharedPreferences.edit().remove(PREF_USER_PASSWORD).apply()
  }

  suspend fun validateToken(token: String): Boolean {
    return getValidateToken(token)
  }

  suspend fun refreshSession():Boolean {
    val credentials = getCredentials()
    val response = login(credentials.email!!, credentials.password!!)
    if (response == "Successful Login!") {
      return true
    }
    return false
  }

  suspend fun getSessionToken(): String {
    val sharedPreferences = getEncryptedSharedPreferences()

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
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().putString(PREF_SESSION_TOKEN, token).apply()
  }

  private fun saveCredentials(email: String, password: String) {
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().putString(PREF_USER_EMAIL, email).apply()
    sharedPreferences.edit().putString(PREF_USER_PASSWORD, password).apply()
  }

  private fun getCredentials(): UserLoginDTO {
    val sharedPreferences = getEncryptedSharedPreferences()

    val email = sharedPreferences.getString(PREF_USER_EMAIL, "")
    val password = sharedPreferences.getString(PREF_USER_PASSWORD, "")
    if (email != null && password != null) {
      return UserLoginDTO(email, password)
    }
    return UserLoginDTO("", "")
  }

  private fun getEncryptedSharedPreferences(): SharedPreferences {
    // Create or retrieve a master key
    val masterKey =
        MasterKey.Builder(appContext, MasterKey.DEFAULT_MASTER_KEY_ALIAS)
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
    
  fun hasCredentials(): Boolean {
    val userLoginDTO = getCredentials()
    if (userLoginDTO.email?.isNotEmpty() == true && userLoginDTO.password?.isNotEmpty() == true) {
      return true
    }
    return false
  }
  
  suspend fun isActivated(): String? {
    val userLoginDTO = getCredentials()
    val response = login(userLoginDTO.email!!, userLoginDTO.password!!)
    return response
  }
  
  suspend fun isLoggedIn(): Boolean {
    val userLoginDTO = getCredentials()
    val token = getSessionToken()
    if (userLoginDTO.email?.isNotEmpty() == true && userLoginDTO.password?.isNotEmpty() == true) {
      if (validateToken(token)) {
        return true
      } else {
        try {
          return refreshSession()
        } catch (e: Exception) {
          return false
        }
      }
    }
    return false
  }
}
