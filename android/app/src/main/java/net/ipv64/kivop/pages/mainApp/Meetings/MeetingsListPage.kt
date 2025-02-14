// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.pages.mainApp.Meetings

import GenerateTabs
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
  LaunchedEffect(Unit) { meetingsViewModel.fetchMeetings() }

  val meetings = meetingsViewModel.meetings
  var tabs = listOf<String>()
  val scheduledMeetings = meetings.filter { it?.status == MeetingStatus.scheduled }
  val completedMeetings = meetings.filter { it?.status == MeetingStatus.completed }
  var inSessionMeetings = meetings.filter { it?.status == MeetingStatus.inSession }

  if (inSessionMeetings.isEmpty()) {
    tabs = listOf("Anstehende Sitzungen", "Vergangene Sitzungen")
  } else {
    tabs = listOf("Laufende Sitzungen", "Anstehende Sitzungen", "Vergangene Sitzungen")
  }

  // Tab-Inhalte definieren
  val tabContents: List<@Composable () -> Unit> =
      if (inSessionMeetings.isEmpty()) {
        listOf(
            {
              LazyColumn(
                  modifier = Modifier.fillMaxHeight(),
                  verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(scheduledMeetings) { meeting ->
                      if (meeting != null) {
                        ListenItem(
                            itemListData = meeting,
                            onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                      }
                    }
                  }
            },
            {
              LazyColumn(
                  modifier = Modifier.fillMaxHeight(),
                  verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(completedMeetings) { meeting ->
                      if (meeting != null) {
                        ListenItem(
                            itemListData = meeting,
                            onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                      }
                    }
                  }
            })
      } else {
        listOf(
            {
              LazyColumn(
                  modifier = Modifier.fillMaxHeight(),
                  verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(inSessionMeetings) { meeting ->
                      if (meeting != null) {
                        ListenItem(
                            itemListData = meeting,
                            onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                      }
                    }
                  }
            },
            {
              LazyColumn(
                  modifier = Modifier.fillMaxHeight(),
                  verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(scheduledMeetings) { meeting ->
                      if (meeting != null) {
                        ListenItem(
                            itemListData = meeting,
                            onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                      }
                    }
                  }
            },
            {
              LazyColumn(
                  modifier = Modifier.fillMaxHeight(),
                  verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    items(completedMeetings) { meeting ->
                      if (meeting != null) {
                        ListenItem(
                            itemListData = meeting,
                            onClick = { navController.navigate("anwesenheit/${meeting.id}") })
                      }
                    }
                  }
            })
      }

  // Layout mit Tabs und aktuellen Meetings
  Column(modifier = Modifier.padding(18.dp)) {
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
