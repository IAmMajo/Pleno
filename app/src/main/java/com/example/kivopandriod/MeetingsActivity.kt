package com.example.kivopandriod


import AppointmentTabContent
import Login
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.annotation.RequiresApi
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import com.example.kivopandriod.components.MeetingData
import com.example.kivopandriod.components.TermindData
import com.example.kivopandriod.components.meetingsList
import kotlinx.coroutines.launch

class MeetingActivity : ComponentActivity() {
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
    val tabs = listOf("anstehende Sitzungen", "vergangenen Sitzungen")
    val scope = rememberCoroutineScope()
    var meetings by remember { mutableStateOf<List<MeetingData>>(emptyList()) }

    LaunchedEffect(Unit) {
        scope.launch {
            // Login zuerst ausführen
            Login(email = "admin@kivop.ipv64.net", password = "admin")
            Log.d("Login", "Login erfolgreich: ${TokenManager.jwtToken}")

            // Meetings abrufen
            val result = meetingsList()
            println("Meetings abgerufen: ${result.size} Einträge.")
            meetings = result
        }
    }

    // Konvertierung in TermindData (falls nötig)
    val appointments = meetings.mapIndexed { index, meeting ->
        TermindData(
            title = meeting.name,
            date = meeting.date,
            time = meeting.time,
            status = 0
        )
    }

    // Ergebnisse anzeigen
    AppointmentTabContent(
        tabs = tabs,
        appointments = appointments
    )
}
