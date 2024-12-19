package net.ipv64.kivop.pages

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
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
import com.example.kivopandriod.moduls.SitzungsCardData
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.components.ResponseList
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.services.api.getMeetingsByID
import net.ipv64.kivop.services.api.responseList

@Composable
fun AttendancesCoordinationPage(navController: NavController? = null, meetingId: String) {

  // Zustand für die Antworten (Liste von ResponseItem)
  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  var responseSitzungsCard by remember { mutableStateOf<GetMeetingDTO?>(null) }

  // API-Anfrage ausführen Response
  LaunchedEffect(meetingId) {
    val responseData = responseList(meetingId, navController!!.context) // Dynamische Daten abrufen
    responses =
        responseData.map { response ->
          ResponseItem(name = response.name, statusIconResId = response.status)
        }
  }

  // API-Anfrage ausführen SitzungsCard
  LaunchedEffect(meetingId) {
    responseSitzungsCard = navController?.let { getMeetingsByID(it.context, id = meetingId) }
  }

  // UI anzeigen
  Column(modifier = Modifier.background(Color.Transparent)) {
    responseSitzungsCard?.let { sitzungsCardData -> SitzungsCard(sitzungsCardData) }
    Log.d("Test-log-page", "AttendancesCoordinationPage: $responseSitzungsCard")
    Spacer(Modifier.size(12.dp))
    ResponseList(responses = responses, "Rückmeldungen")
  }
}
