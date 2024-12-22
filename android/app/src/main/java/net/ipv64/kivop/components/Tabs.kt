
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.example.kivopandriod.components.Subtitles
import net.ipv64.kivop.components.ListenItem
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus

@Composable
fun GenerateTabs(tabs: List<String>, selectedTabIndex: Int, onTabSelected: (Int) -> Unit) {
  TabRow(
      selectedTabIndex = selectedTabIndex,
      modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 12.dp),
      containerColor = Color.Transparent,
      indicator = { tabPositions ->
        Box(
            modifier =
                Modifier.tabIndicatorOffset(tabPositions[selectedTabIndex])
                    .height(3.dp)
                    .background(
                        color = Color.Black,
                        shape = RoundedCornerShape(topStart = 10.dp, topEnd = 10.dp)))
      }) {
        tabs.forEachIndexed { index, title ->
          Tab(
              selected = selectedTabIndex == index,
              onClick = { onTabSelected(index) },
              text = {
                Text(
                    text = title,
                    color = if (selectedTabIndex == index) Color.Black else Color.Gray,
                )
              })
        }
      }
}

@Composable
fun AppointmentTabContent(
    navigation: NavController,
    tabs: List<String>,
    appointments: List<GetMeetingDTO>
) {
  var selectedTabIndex by remember { mutableStateOf(0) }

  Column(modifier = Modifier.fillMaxSize()) {
    // Tabs werden oben eingebunden
    GenerateTabs(
        tabs = tabs, selectedTabIndex = selectedTabIndex, onTabSelected = { selectedTabIndex = it })

    // Inhalt unterhalb der Tabs
    LazyColumn(modifier = Modifier.fillMaxSize().padding(18.dp),verticalArrangement = Arrangement.spacedBy(12.dp)) {
      var previousYear: Int? = null // Zustand für das vorherige Jahr

      when (selectedTabIndex) {
        0 -> {
          // Anstehende Sitzungen
          val upcomingAppointments =
              appointments.filter { appointment: GetMeetingDTO ->
                appointment.status == MeetingStatus.scheduled || appointment.status == MeetingStatus.inSession
              }
          if (upcomingAppointments.isNotEmpty()) {
            items(upcomingAppointments.size) { index ->
              val currentYear = upcomingAppointments[index].start?.year
              val shouldRenderSubtitle = currentYear != previousYear
              if (shouldRenderSubtitle) {
                previousYear = currentYear
                Subtitles(subText = currentYear?.toString() ?: "")
              }
              ListenItem(
                  itemListData = upcomingAppointments[index],
                  onClick = {
                    navigation.navigate("anwesenheit/${upcomingAppointments[index].id}")
                  })
              Spacer(modifier = Modifier.size(8.dp))
            }
          } else {
            item { Text("Keine anstehenden Sitzungen", color = Color.Gray) }
          }
        }

        1 -> {
          // Vergangene Sitzungen
          val pastAppointments =
              appointments.filter { appointment: GetMeetingDTO -> 
                appointment.status == MeetingStatus.completed }
          if (pastAppointments.isNotEmpty()) {
            items(pastAppointments.size) { index ->
              val currentYear = pastAppointments[index].start?.year
              val shouldRenderSubtitle = currentYear != previousYear
              if (shouldRenderSubtitle) {
                previousYear = currentYear
                Subtitles(subText = currentYear?.toString() ?: "")
              }
              ListenItem(
                  itemListData = pastAppointments[index],
                  onClick = { navigation.navigate("anwesenheit/${pastAppointments[index].id}") })
              Spacer(modifier = Modifier.size(8.dp))
            }
          } else {
            item { Text("Keine vergangenen Sitzungen", color = Color.Gray) }
          }
        }
      }
    }
  }
}
