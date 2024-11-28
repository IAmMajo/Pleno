package com.example.kivopandriod.pages

import AppointmentTabContent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.navigation.NavController
import com.example.kivopandriod.services.MeetingData
import com.example.kivopandriod.components.TermindData
import com.example.kivopandriod.services.meetingsList
import kotlinx.coroutines.launch

@Composable
fun AnwesenheitScreen(navController: NavController){
    val tabs = listOf("anstehende Sitzungen", "vergangenen Sitzungen")
    val scope = rememberCoroutineScope()
    var meetings by remember { mutableStateOf<List<MeetingData>>(emptyList()) }

    LaunchedEffect(Unit) {
        scope.launch {
            // Login zuerst ausführen

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
            status = 0,
            id = meeting.id
        )
    }

    // Ergebnisse anzeigen
    AppointmentTabContent(
        navController,
        tabs = tabs,
        appointments = appointments
    )
}