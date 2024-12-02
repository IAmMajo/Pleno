package com.example.kivopandriod.pages


import Login
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.kivopandriod.components.ResponseItem
import com.example.kivopandriod.components.ResponseList
import com.example.kivopandriod.components.SitzungsCard
import com.example.kivopandriod.services.responseList
import java.time.LocalDate


@Composable
fun ResponseScreen(
    navController: NavController? = null,
    meetingId: String

) {
    //TODO: FIX THIS
        Surface() {
            // Zustand für die Antworten (Liste von ResponseItem)
            var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
            // API-Anfrage ausführen
            LaunchedEffect(meetingId)
            {
                val responseData = responseList(meetingId) // Dynamische Daten abrufen
                responses = responseData.map { response ->
                    ResponseItem(name = response.name, statusIconResId = response.status)
                }
            }
            println(responses)
            // UI anzeigen
            val eventDate = LocalDate.of(2024, 10, 24) // 24.10.2024
            Column(
                modifier = Modifier.background(Color.Transparent)
            ) {

                SitzungsCard(title = "Vorstandswahl", date = eventDate)
                Spacer(Modifier.size(12.dp))
                ResponseList(responses = responses, "Rückmeldungen")
            }
        }
    }


