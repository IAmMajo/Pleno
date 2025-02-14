// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
  // Versucht, den Nutzer mit der angegebenen E-Mail und dem Passwort anzumelden.  
  // Speichert das Session-Token und die Anmeldedaten bei Erfolg.  
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
  // Registriert einen neuen Nutzer.  
  // Speichert die Anmeldedaten lokal, falls die Registrierung erfolgreich war.  
  suspend fun register(user: UserRegistrationDTO): Boolean {
    if (postRegister(user)) {
      saveCredentials(user.email!!, user.password!!)
      return true
    }
    return false
  }
  // Sendet die Bestätigungs-E-Mail erneut an die hinterlegte E-Mail-Adresse.
  suspend fun resendEmail() {
    val credentials = getCredentials()
    postResendEmail(credentials.email!!)
  }
  // Löscht die gespeicherten Anmeldedaten und das Session-Token.
  fun logout() {
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().remove(PREF_SESSION_TOKEN).apply()
    sharedPreferences.edit().remove(PREF_USER_EMAIL).apply()
    sharedPreferences.edit().remove(PREF_USER_PASSWORD).apply()
  }
  // Prüft, ob das angegebene Session-Token gültig ist.  
  suspend fun validateToken(token: String): Boolean {
    return getValidateToken(token)
  }
  // Aktualisiert das Session-Token, falls der alte abgelaufen ist.  
  suspend fun refreshSession(): Boolean {
    val credentials = getCredentials()
    val response = login(credentials.email!!, credentials.password!!)
    if (response == "Successful Login!") {
      return true
    }
    return false
  }
  // Holt den Session-Token aus den EncryptedSharedPreference. 
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
  // Speichert den Session-Token in die EncryptedSharedPreference.
  private fun saveSessionToken(token: String) {
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().putString(PREF_SESSION_TOKEN, token).apply()
  }
  // Speichert die Anmeldedaten in die EncryptedSharedPreference.
  private fun saveCredentials(email: String, password: String) {
    val sharedPreferences = getEncryptedSharedPreferences()

    sharedPreferences.edit().putString(PREF_USER_EMAIL, email).apply()
    sharedPreferences.edit().putString(PREF_USER_PASSWORD, password).apply()
  }
  // Holt die Anmeldedaten aus den EncryptedSharedPreference.
  private fun getCredentials(): UserLoginDTO {
    val sharedPreferences = getEncryptedSharedPreferences()

    val email = sharedPreferences.getString(PREF_USER_EMAIL, "")
    val password = sharedPreferences.getString(PREF_USER_PASSWORD, "")
    if (email != null && password != null) {
      return UserLoginDTO(email, password)
    }
    return UserLoginDTO("", "")
  }
  // Holt die EncryptedSharedPreference.
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
  // Prüft, ob die Anmeldedaten existieren.
  fun hasCredentials(): Boolean {
    val userLoginDTO = getCredentials()
    if (userLoginDTO.email?.isNotEmpty() == true && userLoginDTO.password?.isNotEmpty() == true) {
      return true
    }
    return false
  }
  // Prüft, ob der User freigeschaltet ist. (Email bestätigt)
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
