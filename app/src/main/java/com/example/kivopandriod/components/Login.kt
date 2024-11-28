import com.google.gson.Gson
import com.google.gson.JsonObject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

object TokenManager {
    var jwtToken: String? = null
}

suspend fun Login(email: String, password: String) {
    val url = "https://kivop.ipv64.net/auth/login"
    val client = OkHttpClient()

    val jsonPayload = JsonObject().apply {
        addProperty("email", email)
        addProperty("password", password)
    }.toString()

    val requestBody = jsonPayload.toRequestBody("application/json; charset=utf-8".toMediaType())
    val request = Request.Builder()
        .url(url)
        .post(requestBody)
        .build()

    withContext(Dispatchers.IO) {
        try {
            println("Login: Sende Anfrage an $url mit Payload: $jsonPayload")
            val response = client.newCall(request).execute()
            if (response.isSuccessful) {
                val responseBody = response.body?.string()
                if (responseBody != null) {
                    val jsonResponse = Gson().fromJson(responseBody, JsonObject::class.java)
                    val token = jsonResponse.get("token")?.asString
                    if (!token.isNullOrEmpty()) {
                        TokenManager.jwtToken = token
                        println("TokenManager: Token erfolgreich gespeichert: $token")
                    } else {
                        println("TokenManager: Kein Token im Response gefunden: $jsonResponse")
                    }
                } else {
                    println("TokenManager: Fehler: Leerer Response")
                }
            } else {
                println("TokenManager: Fehler bei der Anfrage: ${response.code}, ${response.body?.string()}")
            }
        } catch (e: Exception) {
            println("TokenManager: Fehler: ${e.message}")
        }
    }
}

suspend fun main() {
    Login("admin@kivop.ipv64.net", "admin")
    println("TokenManager: Token ist ${TokenManager.jwtToken}")
}
