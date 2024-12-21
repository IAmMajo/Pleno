package net.ipv64.kivop.pages.mainApp

import androidx.compose.runtime.Composable
import androidx.navigation.NavController

@Composable
fun AttendancesCoordinationPage(navController: NavController? = null, meetingId: String) {
  /*
  // Zustand für die Antworten (Liste von ResponseItem)
  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  var responseSitzungsCard by remember { mutableStateOf<GetMeetingDTO?>(null) }

  // API-Anfrage ausführen Response
  LaunchedEffect(meetingId) {
    val responseData = getAttendances(meetingId, navController!!.context) // Dynamische Daten abrufen
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
  */
}
