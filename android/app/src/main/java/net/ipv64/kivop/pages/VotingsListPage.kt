package com.example.kivopandriod.pages

import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Text
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
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.GetVotings
import net.ipv64.kivop.models.ItemListData

@Composable
fun VotingsListPage(navController: NavController) {
  var votings by remember { mutableStateOf<List<GetVotingDTO>>(emptyList()) }
  val scope = rememberCoroutineScope()

  LaunchedEffect(Unit) {
    scope.launch {
      val result = GetVotings(navController.context)
      votings = result
    }
  }

  Column(modifier = Modifier.fillMaxSize()) {
    Text(text = "Votings")
    LazyColumn() {
      items(votings) { voting ->
        var votingData =
            ItemListData(
                title = voting.question,
                id = voting.id.toString(),
                date = null,
                time = null,
                meetingStatus = "",
                timeRend = false,
                iconRend = false)
        try {
          votingData =
              ItemListData(
                  title = voting.question,
                  id = voting.id.toString(),
                  date = voting.startedAt!!.toLocalDate(),
                  time = null,
                  meetingStatus = "",
                  timeRend = false,
                  iconRend = false)
        } catch (e: Exception) {
          Log.d("test", e.message.toString())
          Log.d("test", voting.question)
        }
        ListenItem(
            votingData,
            onClick = {
              var route = ""
              if (voting.isOpen == true) {
                route = "abstimmen/${voting.id}"
              } else {
                route = "abstimmung/${voting.id}"
              }
              navController.navigate(route)
            })
        Spacer(modifier = Modifier.size(8.dp))
      }
    }
  }
}
