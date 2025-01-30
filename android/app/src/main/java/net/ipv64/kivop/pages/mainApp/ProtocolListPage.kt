package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
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
fun ProtocolListPage(navController: NavController, meetingsViewModel: MeetingsViewModel) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  val meetings = meetingsViewModel.meetings

  Column {
    SpacerTopBar()

    LazyColumn(modifier = Modifier.fillMaxHeight()) {
      items(meetings) { meeting ->
        if (meeting != null && meeting.status != MeetingStatus.scheduled) {
          ListenItem(
              itemListData = meeting,
              onClick = { navController.navigate("protokolleDetail/${meeting.id}") },
              isProtokoll = true)
          Spacer(modifier = Modifier.height(12.dp))
        }
      }
    }
  }
}
