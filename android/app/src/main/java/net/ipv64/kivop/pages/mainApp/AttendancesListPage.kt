package net.ipv64.kivop.pages.mainApp

import GenerateTabs
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.ListenItem
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.services.api.getMeetings

@Composable
fun AttendancesListPage(navController: NavController) {
  val tabs = listOf("Anstehende Sitzungen", "Vergangene Sitzungen")
  val scope = rememberCoroutineScope()
  var meetings by remember { mutableStateOf<List<GetMeetingDTO>>(emptyList()) }

  LaunchedEffect(Unit) {
    scope.launch {
      // Login zuerst ausführen

      // Meetings abrufen
      val result = getMeetings(navController.context)
      meetings = result
    }
  }

  val scheduledMeetings = meetings.filter { it.status == MeetingStatus.scheduled }
  val completedMeetings = meetings.filter { it.status == MeetingStatus.completed }
  val inSessionMeetings = meetings.filter { it.status == MeetingStatus.inSession }

  // Tab-Inhalte definieren
  val tabContents =
      listOf<@Composable () -> Unit>(
          {
            LazyColumn(
                modifier = Modifier.fillMaxHeight(),
                verticalArrangement = Arrangement.spacedBy(12.dp)) {
                  items(scheduledMeetings) { meeting ->
                    ListenItem(
                        itemListData = meeting,
                        onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                  }
                }
          },
          {
            LazyColumn(
                modifier = Modifier.fillMaxHeight(),
                verticalArrangement = Arrangement.spacedBy(12.dp)) {
                  items(completedMeetings) { meeting ->
                    ListenItem(
                        itemListData = meeting,
                        onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                  }
                }
          })

  // Layout mit Tabs und aktuellen Meetings
  Column {
    // Aktuelle Meetings anzeigen
    LazyColumn(
        modifier = Modifier.heightIn(max = 210.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)) {
          items(inSessionMeetings) { meeting ->
            ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") })
          }
        }
    Spacer(Modifier.size(18.dp))
    // Tabs anzeigen
    GenerateTabs(tabs = tabs, tabContents = tabContents)
  }
}
