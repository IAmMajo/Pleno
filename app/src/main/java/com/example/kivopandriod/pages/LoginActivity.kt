package com.example.kivopandriod.pages

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.example.kivopandriod.R
import com.example.kivopandriod.components.TokenManager
import com.example.kivopandriod.components.Login
import kotlinx.coroutines.runBlocking

class LoginActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)


        // Test des TokenManagers
        testTokenManager()
    }

    private fun testTokenManager() {
        val testToken : String?
        runBlocking {
            testToken = Login("admin@kivop.ipv64.net", "admin")
        }
        // Speichern des Tokens
        TokenManager.saveToken(context = this, newToken = testToken)
        println("Token gespeichert!")

        // Abrufen des Tokens
        val retrievedToken = TokenManager.getToken(context = this)
        println("Abgerufener Token: $retrievedToken")

        // Löschen des Tokens
        TokenManager.clearToken(context = this)
        println("Token gelöscht!")

        // Versuch, den gelöschten Token abzurufen
        val afterClearToken = TokenManager.getToken(context = this)
        println("Token nach Löschen: $afterClearToken")
    }
}
