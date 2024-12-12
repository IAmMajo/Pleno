package net.ipv64.kivop.pages

import AppointmentTabContent
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.moduls.AttendancesListsData
import net.ipv64.kivop.services.api.meetingsList
import net.ipv64.kivop.ui.theme.*

@Composable
fun AttendancesListPage(navController: NavController) {
  val tabs = listOf("anstehende Sitzungen", "vergangenen Sitzungen")
  val scope = rememberCoroutineScope()
  var meetings by remember { mutableStateOf<List<AttendancesListsData>>(emptyList()) }

  //    val colorH: Color = when (STATUS) {
  //        0 -> Background_secondary_light
  //        1 -> Primary_dark_20
  //        else -> Error_dark_20
  //    }

  LaunchedEffect(Unit) {
    scope.launch {
      // Login zuerst ausführen

      // Meetings abrufen
      val result = meetingsList(navController.context)
      meetings = result
    }
  }

  // Konvertierung in TermindData (falls nötig)
  val appointments =
      meetings.mapIndexed { index, meeting ->
        AttendancesListsData(
            title = meeting.title,
            date = meeting.date,
            time = meeting.time,
            attendanceStatus = 0,
            id = meeting.id)
      }

  // Ergebnisse anzeigen
  AppointmentTabContent(navController, tabs = tabs, appointments = appointments)
}
