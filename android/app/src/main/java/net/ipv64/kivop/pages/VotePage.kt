package net.ipv64.kivop.pages

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.navigation.NavController
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.GetVotingByID
import net.ipv64.kivop.ui.theme.Background_prime
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.components.VoteOptions
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.ui.theme.Primary
import java.util.UUID

@Composable
fun VotePage(navController: NavController, votingID: String) {
  var votingData by remember { mutableStateOf<GetVotingDTO?>(null) }
  LaunchedEffect(Unit) {
    votingData = GetVotingByID(navController.context, UUID.fromString(votingID))
  }
  votingData?.let { Vote(navController, it) }
}

@Composable
fun Vote(navController: NavController, votingData: GetVotingDTO) {
  var meetingData by remember { mutableStateOf<GetMeetingDTO?>(null) }
  var votedIndex by remember { mutableIntStateOf(-1) }
  LaunchedEffect(Unit) { 
    meetingData = getMeetingByID(navController.context, votingData.meetingId.toString())
  }
  
  Column(
    modifier = Modifier
      .background(Primary)
  ) {
    Text(text = votingData.description, color = Background_prime)
    Row { 
      
    }
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .fillMaxHeight()
        .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
        .background(Background_prime)
        .padding(18.dp)
    ) {
      VoteOptions(votingData.options, onCheckedChange = {votedIndex = it})
    }
  }
}

@Composable
fun AlreadyVoted(navController: NavController, votingID: String) {
  
}