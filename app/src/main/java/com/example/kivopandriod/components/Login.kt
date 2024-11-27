import okhttp3.*
import com.google.gson.JsonObject
import com.google.gson.Gson
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.RequestBody.Companion.toRequestBody

object TokenManager {
    var jwtToken: String? = null // Globale Speicherung des Tokens
}

fun authenticateUser(email: String, password: String) {
    val url = "https://kivop.ipv64.net/auth/login"
    val client = OkHttpClient()

    // JSON-Payload mit Gson erstellen
    val jsonPayload = JsonObject().apply {
        addProperty("email", email)
        addProperty("password", password)
    }.toString()

    val requestBody = jsonPayload.toRequestBody("application/json; charset=utf-8".toMediaType())
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .build()

    try {
        val response = client.newCall(request).execute() // Synchrone Ausführung
        if (response.isSuccessful) {
            val responseBody = response.body?.string()
            if (responseBody != null) {
                val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
                val token = jsonResponse.get("token")?.asString // Token aus JSON extrahieren
                if (!token.isNullOrEmpty()) {
                    TokenManager.jwtToken = token // Token in TokenManager speichern
                } else {
                    println("Fehler: Kein Token gefunden")
                }
            } else {
                println("Fehler: Leerer Response")
            }
        } else {
            println("Fehler bei der Anfrage: ${response.message}")
        }
    } catch (e: Exception) {
        println("Fehler: ${e.message}")
    }
}

/*
fun main() {
    authenticateUser("admin@kivop.ipv64.net", "admin")
    println(TokenManager.jwtToken)
}
*/