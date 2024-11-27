package com.example.kivopandriod.components

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.ktor.client.*
import io.ktor.client.engine.cio.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import com.google.gson.JsonParser


suspend fun Login(email: String, password: String): String? {
    val client = HttpClient(CIO)

    val requestBody = """
        {
            "email": "$email",
            "password": "$password",
            
        }
    """.trimIndent()

    return try {
        val response: HttpResponse = client.post("https://kivop.ipv64.net/auth/login") {
            contentType(ContentType.Application.Json)
            setBody(requestBody)
        }

        val responseText = response.bodyAsText()

        val jsonElement = JsonParser.parseString(responseText).asJsonObject
        val token = jsonElement["token"]?.asString
        return  token // Gib nur den Token zurück
    } catch (e: Exception) {
        println("Error: ${e.message}")
        null
    } finally {
        client.close()
    }
}



object TokenManager {
    private var token: String? = null
    private const val date_name = "data"
    private const val JWT_key_name = "JWT_TOKEN"

    private fun getEncryptedSharedPreferences(context: Context): SharedPreferences {
        // Erstelle den MasterKey
        val masterKey = MasterKey.Builder(context)
            .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
            .build()

        // Verwende die aktualisierte Methode, die ein MasterKey-Objekt akzeptiert
        return EncryptedSharedPreferences.create(
            context, // Kontext
            date_name, // Name der Datei
            masterKey, // MasterKey-Objekt
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun saveToken(context: Context, newToken: String?) {
        // Speichere Token im Singleton
        token = newToken

        // Speichere den verschlüsselten Token in SharedPreferences
        val encryptedPrefs = getEncryptedSharedPreferences(context)
        encryptedPrefs.edit().putString(JWT_key_name, newToken).apply()
    }

    fun getToken(context: Context): String? {
        // Falls Token im Singleton null ist, lade es aus SharedPreferences
        if (token == null) {
            val encryptedPrefs = getEncryptedSharedPreferences(context)
            token = encryptedPrefs.getString(JWT_key_name, null)
        }
        return token
    }

    fun clearToken(context: Context) {
        // Lösche den Token aus dem Singleton
        token = null

        // Entferne den verschlüsselten Token aus SharedPreferences
        val encryptedPrefs = getEncryptedSharedPreferences(context)
        encryptedPrefs.edit().remove(JWT_key_name).apply()
    }
}
