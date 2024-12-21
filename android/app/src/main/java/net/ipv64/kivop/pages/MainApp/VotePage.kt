package net.ipv64.kivop.pages.MainApp

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.AbstimmungCard
import net.ipv64.kivop.components.VoteOptions
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.GetVotingByID
import net.ipv64.kivop.models.putVote
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun VotePage(navController: NavController, votingID: String) {
  var votingData by remember { mutableStateOf<GetVotingDTO?>(null) }
  var meetingData by remember { mutableStateOf<GetMeetingDTO?>(null) }
  var votedIndex by remember { mutableIntStateOf(-1) }
  var scope = rememberCoroutineScope()
  LaunchedEffect(Unit) {
    votingData = GetVotingByID(navController.context, UUID.fromString(votingID))
    meetingData = getMeetingByID(navController.context, votingData!!.meetingId.toString())
  }

  Column(modifier = Modifier.background(Primary)) {
    if (votingData != null) {
      AbstimmungCard(
          title = votingData!!.question,
          date = votingData!!.startedAt,
          eventType = meetingData?.name)
    }
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .fillMaxHeight()
                .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                .background(Background_prime)
                .padding(18.dp)) {
          votingData?.let { VoteOptions(it.options, onCheckedChange = { votedIndex = it }) }
          Spacer(modifier = Modifier.weight(1f))
          Column {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Secondary, contentColor = Text_tertiary),
                onClick = {
                  // todo: ask if user is sure
                  scope.launch {
                    val voted = putVote(navController.context, votingID, 0)
                    if (!voted) {
                      Toast.makeText(
                              navController.context, "Fehler beim Abstimmen", Toast.LENGTH_SHORT)
                          .show()
                    } else {
                      navController.navigate("abgestimmt/${votingID}")
                    }
                  }
                },
            ) {
              Text(text = "Enthalten", fontSize = 20.sp)
            }
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Primary, contentColor = Background_secondary),
                onClick = {
                  // todo: ask if user is sure
                  if (votedIndex != -1) {
                    scope.launch {
                      val voted = putVote(navController.context, votingID, votedIndex)
                      if (!voted) {
                        Toast.makeText(
                                navController.context, "Fehler beim Abstimmen", Toast.LENGTH_SHORT)
                            .show()
                      } else {
                        navController.navigate("abgestimmt/${votingID}")
                      }
                    }
                  } else {
                    Toast.makeText(
                            navController.context,
                            "Bitte wählen Sie eine Option aus",
                            Toast.LENGTH_SHORT)
                        .show()
                  }
                },
            ) {
              Text(text = "Abstimmen", fontSize = 20.sp)
            }
          }
        }
  }
}
