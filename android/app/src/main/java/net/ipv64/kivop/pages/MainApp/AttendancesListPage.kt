package net.ipv64.kivop.pages.mainApp

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
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.services.api.getMeetings

@Composable
fun AttendancesListPage(navController: NavController) {
  val tabs = listOf("anstehende Sitzungen", "vergangenen Sitzungen")
  val scope = rememberCoroutineScope()
  var meetings by remember { mutableStateOf<List<GetMeetingDTO>>(emptyList()) }

  //    val colorH: Color = when (STATUS) {
  //        0 -> Background_secondary_light
  //        1 -> Primary_dark_20
  //        else -> Error_dark_20
  //    }

  LaunchedEffect(Unit) {
    scope.launch {
      // Login zuerst ausführen

      // Meetings abrufen
      val result = getMeetings(navController.context)
      meetings = result
    }
  }
  
  // Log.i("AttendancesListPage", "Appointments: ${appointments}")
  // Ergebnisse anzeigen
  AppointmentTabContent(navController, tabs = tabs, appointments = meetings)
}
