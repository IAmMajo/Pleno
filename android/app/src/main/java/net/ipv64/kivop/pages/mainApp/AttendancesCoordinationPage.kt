package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
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
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.AttendanceCoordinationList
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.ui.theme.Text_secondary

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AttendancesCoordinationPage(navController: NavController, meetingId: String) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  // Zustand für die Antworten (Liste von ResponseItem)
  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  var responseSitzungsCard by remember { mutableStateOf<GetMeetingDTO?>(null) }

  // API-Anfrage ausführen Response
  LaunchedEffect(meetingId) {
    val responseData = getAttendances(meetingId) // Dynamische Daten abrufen
    responses =
        responseData.map { response ->
          ResponseItem(name = response.identity.name, status = response.status)
        }
  }

  // API-Anfrage ausführen SitzungsCard
  LaunchedEffect(meetingId) {
    responseSitzungsCard = navController?.let { getMeetingByID(id = meetingId) }
  }

  // UI anzeigen
  Column {
    SpacerTopBar()
    Log.d("Sit", "$responseSitzungsCard")
    responseSitzungsCard?.let { sitzungsCardData -> SitzungsCard(sitzungsCardData) }
    Spacer(Modifier.size(12.dp))

    val pendingList = responses.filter { it.status == null }
    val presentList = responses.filter { it.status == AttendanceStatus.present }
    val absentList = responses.filter { it.status == AttendanceStatus.absent }
    val acceptedList = responses.filter { it.status == AttendanceStatus.accepted }
    var maxMembernumber = responses.size
    var isPendingVisible by remember { mutableStateOf(true) }
    var isPresentVisible by remember { mutableStateOf(true) }
    var isAbsentVisible by remember { mutableStateOf(true) }
    var isAcceptedVisible by remember { mutableStateOf(true) }

    LazyColumn(
        modifier = Modifier.fillMaxWidth().fillMaxHeight(),
        verticalArrangement = Arrangement.spacedBy(12.dp)) {
          AttendanceCoordinationList(
              title = "Present",
              responses = presentList,
              isVisible = isPresentVisible,
              maxMembernumber = maxMembernumber,
              background = Text_secondary,
              onVisibilityToggle = { isPresentVisible = it })
          if (responseSitzungsCard?.status == MeetingStatus.scheduled ||
              responseSitzungsCard?.status == MeetingStatus.inSession) {
            AttendanceCoordinationList(
                title = "Zugesagt",
                responses = acceptedList,
                isVisible = isAcceptedVisible,
                maxMembernumber = maxMembernumber,
                background = Color(color = 0xff1061DA),
                onVisibilityToggle = { isAcceptedVisible = it })
            AttendanceCoordinationList(
                title = "Ausstehend",
                responses = pendingList,
                isVisible = isPendingVisible,
                maxMembernumber = maxMembernumber,
                onVisibilityToggle = { isPendingVisible = it })
            AttendanceCoordinationList(
                title = "Abgesagt",
                responses = absentList,
                isVisible = isAbsentVisible,
                maxMembernumber = maxMembernumber,
                background = Color(color = 0xffDA1043),
                onVisibilityToggle = { isAbsentVisible = it })
          } else {
            AttendanceCoordinationList(
                title = "Abwesend",
                responses = absentList,
                isVisible = isAbsentVisible,
                maxMembernumber = maxMembernumber,
                background = Color(color = 0xffDA1043),
                onVisibilityToggle = { isAbsentVisible = it })
          }
        }
  }
}
