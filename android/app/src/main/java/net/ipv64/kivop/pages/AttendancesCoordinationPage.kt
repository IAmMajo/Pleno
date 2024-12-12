package net.ipv64.kivop.pages

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
import java.time.LocalDate
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.components.ResponseList
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.services.api.responseList

@Composable
fun AttendancesCoordinationPage(navController: NavController? = null, meetingId: String) {

  // Zustand für die Antworten (Liste von ResponseItem)
  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  // API-Anfrage ausführen
  LaunchedEffect(meetingId) {
    val responseData = responseList(meetingId, navController!!.context) // Dynamische Daten abrufen
    responses =
        responseData.map { response ->
          ResponseItem(name = response.name, statusIconResId = response.status)
        }
  }
  println(responses)
  // UI anzeigen
  val eventDate = LocalDate.of(2024, 10, 24) // 24.10.2024
  Column(modifier = Modifier.background(Color.Transparent)) {
    SitzungsCard(title = "Vorstandswahl", date = eventDate)
    Spacer(Modifier.size(12.dp))
    ResponseList(responses = responses, "Rückmeldungen")
  }
}
