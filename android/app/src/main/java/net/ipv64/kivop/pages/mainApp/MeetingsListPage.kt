package net.ipv64.kivop.pages.mainApp

import GenerateTabs
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.ListenItem
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.models.viewModel.MeetingsViewModel

@Composable
fun MeetingsListPage(navController: NavController, meetingsViewModel: MeetingsViewModel) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  val meetings = meetingsViewModel.meetings
  var tabs = listOf<String>()
  val scheduledMeetings = meetings.filter { it?.status == MeetingStatus.scheduled }
  val completedMeetings = meetings.filter { it?.status == MeetingStatus.completed }
  var inSessionMeetings = meetings.filter { it?.status == MeetingStatus.inSession }
 

  if(inSessionMeetings.isEmpty()){
    tabs = listOf("Anstehende Sitzungen", "Vergangene Sitzungen")
  }
  else{
    tabs = listOf("Laufende Sitzungen","Anstehende Sitzungen", "Vergangene Sitzungen")
  }

  
  // Tab-Inhalte definieren
  val tabContents: List<@Composable () -> Unit> = if (inSessionMeetings.isEmpty()) {
    listOf(
      {
        LazyColumn(
          modifier = Modifier.fillMaxHeight(),
          verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          items(scheduledMeetings) { meeting ->
            if (meeting != null) {
              ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") }
              )
            }
          }
        }
      },
      {
        LazyColumn(
          modifier = Modifier.fillMaxHeight(),
          verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          items(completedMeetings) { meeting ->
            if (meeting != null) {
              ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") }
              )
            }
          }
        }
      }
    )
  } else {
    listOf(
      {
        LazyColumn(
          modifier = Modifier.fillMaxHeight(),
          verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          items(inSessionMeetings) { meeting ->
            if (meeting != null) {
              ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") }
              )
            }
          }
        }
      },
      {
        LazyColumn(
          modifier = Modifier.fillMaxHeight(),
          verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          items(scheduledMeetings) { meeting ->
            if (meeting != null) {
              ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") }
              )
            }
          }
        }
      },
      {
        LazyColumn(
          modifier = Modifier.fillMaxHeight(),
          verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
          items(completedMeetings) { meeting ->
            if (meeting != null) {
              ListenItem(
                itemListData = meeting,
                onClick = { navController.navigate("anwesenheit/${meeting.id}") }
              )
            }
          }
        }
      }
    )
  }

  // Layout mit Tabs und aktuellen Meetings
  Column {
    SpacerTopBar()
    // Aktuelle Meetings anzeigen
//    LazyColumn(
//        modifier = Modifier.heightIn(max = 210.dp),
//        verticalArrangement = Arrangement.spacedBy(12.dp)) {
//          items(inSessionMeetings) { meeting ->
//            if (meeting != null) {
//              ListenItem(
//                  itemListData = meeting,
//                  onClick = { navController.navigate("anwesenheit/${meeting.id}") })
//            }
//          }
//        }
    Spacer(Modifier.size(18.dp))
    // Tabs anzeigen
    GenerateTabs(tabs = tabs, tabContents = tabContents)
  }
}
