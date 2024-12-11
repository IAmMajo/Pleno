package com.example.kivopandriod.pages

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
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
import com.example.kivopandriod.moduls.Location
import com.example.kivopandriod.moduls.SitzungsCardData
import com.example.kivopandriod.services.api.getMeetingsByID
import com.example.kivopandriod.services.api.responseList
import java.time.LocalDate
import java.time.LocalTime

@Composable
fun AttendancesCoordinationPage(navController: NavController? = null, meetingId: String) {

  // TODO: FIX THIS
  Surface() {
    // Zustand für die Antworten (Liste von ResponseItem)
    var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
    var responseSitzungsCard by remember { mutableStateOf<SitzungsCardData?>(null) }
    
    // API-Anfrage ausführen Response
    LaunchedEffect(meetingId) {
      val responseData =
          responseList(meetingId, navController!!.context) // Dynamische Daten abrufen
      responses =
          responseData.map { response ->
            ResponseItem(name = response.name, statusIconResId = response.status)
          }
    }

    // API-Anfrage ausführen SitzungsCard
    LaunchedEffect(meetingId) {
      responseSitzungsCard = navController?.let { getMeetingsByID(it.context,id = meetingId) }
    }
    
    
    
    // UI anzeigen
    Column(modifier = Modifier.background(Color.Transparent)) {
      responseSitzungsCard?.let { sitzungsCardData ->
        SitzungsCard(sitzungsCardData)
      }
      Log.d("Test-log-page", "AttendancesCoordinationPage: $responseSitzungsCard")
      Spacer(Modifier.size(12.dp))
      ResponseList(responses = responses, "Rückmeldungen")
    }
  }
}
