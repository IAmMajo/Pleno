package com.example.kivopandriod.pages

import AppointmentTabContent
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.navigation.NavController
import com.example.kivopandriod.components.MeetingData
import com.example.kivopandriod.components.TermindData

@Composable
fun SitzungenScreen(navController: NavController){
    val tabs = listOf("anstehende Sitzungen", "vergangenen Sitzungen")
    var meetings by remember { mutableStateOf<List<MeetingData>>(emptyList()) }


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