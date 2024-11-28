package com.example.kivopandriod.pages


import Login
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import com.example.kivopandriod.components.ResponseItem
import com.example.kivopandriod.components.ResponseList
import com.example.kivopandriod.services.responseList

class ResponseActivity : ComponentActivity() {
    @RequiresApi(Build.VERSION_CODES.O)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MainApp()
        }
    }
}


@RequiresApi(Build.VERSION_CODES.O)
@Composable
fun MainApp() {

    MaterialTheme {
        Surface {
            // Zustand für die Antworten (Liste von ResponseItem)
            var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
            val meetingId = "E5EBB6A8-AA2F-42FD-9B55-F30B8D68605D"
            // API-Anfrage ausführen
            LaunchedEffect(meetingId)
            {
                Login(email = "admin@kivop.ipv64.net", password = "admin")
                Log.d("LaunchedEffect","why")
                val responseData = responseList(meetingId) // Dynamische Daten abrufen
                responses = responseData.map { response ->
                    ResponseItem(name = response.name, statusIconResId = response.status)
                }
            }
            println(responses)
            // UI anzeigen
            ResponseList(responses = responses, "Rückmeldungen")
        }
    }
}

