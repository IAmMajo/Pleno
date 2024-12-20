package net.ipv64.kivop.pages

import android.util.Log
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
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.components.AbsentList
import net.ipv64.kivop.components.AcceptedList
import net.ipv64.kivop.components.PendingList
import net.ipv64.kivop.components.PresentList
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.services.api.getMeetingByID

@Composable
fun AttendancesCoordinationPage(navController: NavController? = null, meetingId: String) {

  // Zustand für die Antworten (Liste von ResponseItem)
  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  var responseSitzungsCard by remember { mutableStateOf<GetMeetingDTO?>(null) }

  // API-Anfrage ausführen Response
  LaunchedEffect(meetingId) {
    val responseData = getAttendances(navController!!.context,meetingId) // Dynamische Daten abrufen
    responses =
        responseData.map { response ->
          ResponseItem(name = response.identity.name, status = response.status)
        }
  }

  // API-Anfrage ausführen SitzungsCard
  LaunchedEffect(meetingId) {
    responseSitzungsCard = navController?.let { getMeetingByID(it.context, id = meetingId) }
  }

  // UI anzeigen
  Column() {
    responseSitzungsCard?.let { sitzungsCardData -> SitzungsCard(sitzungsCardData) }
    Log.d("Test-log-page", "AttendancesCoordinationPage: $responseSitzungsCard")
    Spacer(Modifier.size(12.dp))
    val pendingList = responses.filter { it.status == null }
    val presentList = responses.filter { it.status == AttendanceStatus.present }
    val absentList = responses.filter { it.status == AttendanceStatus.absent }
    val acceptedList = responses.filter { it.status == AttendanceStatus.accepted}
    val maxMembernumber = responses.size
    
      PresentList(responses = presentList, maxMembernumber = maxMembernumber)
      AcceptedList(responses = acceptedList, maxMembernumber = maxMembernumber)
      PendingList(responses = pendingList, maxMembernumber = maxMembernumber)
      AbsentList(responses = absentList, maxMembernumber = maxMembernumber)
    
    
  }
 
}
