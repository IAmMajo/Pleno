package net.ipv64.kivop.pages.mainApp.Polls

import android.util.Log
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
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
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.AbstimmungCard
import net.ipv64.kivop.components.Label
import net.ipv64.kivop.components.PollOptions
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.components.VoteOptions
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.GetVotingByID
import net.ipv64.kivop.models.putVote
import net.ipv64.kivop.models.viewModel.PollViewModel
import net.ipv64.kivop.models.viewModel.PollViewModelFactory
import net.ipv64.kivop.models.viewModel.PollsListViewModel
import net.ipv64.kivop.models.viewModel.VotingResultViewModelFactory
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun PollPage(navController: NavController, pollID: String) {
  val pollViewModel: PollViewModel = viewModel(factory = PollViewModelFactory(pollID))
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  
  val scope = rememberCoroutineScope()
  
  Column(modifier = Modifier.background(Primary)) {
    SpacerTopBar()
    if (pollViewModel.poll != null) {
      AbstimmungCard(
        title = pollViewModel.poll!!.question,
        date = pollViewModel.poll!!.startedAt,
        eventType = "")
    }
    Column(
      modifier =
      Modifier.fillMaxWidth()
        .fillMaxHeight()
        .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
        .background(Background_prime)
        .padding(18.dp)) {
      Row {
        if (pollViewModel.poll?.anonymous == true) {
          Label(Primary){
            Text(text = "Anonym", style = TextStyles.contentStyle, color = Text_prime_light)
          }
          SpacerBetweenElements()
        }
        if (pollViewModel.poll?.multiSelect == true){
          Label(Primary){
            Text(text = "Mehrfachauswahl", style = TextStyles.contentStyle, color = Text_prime_light)
          }
        } else{
          Label(Primary){
            Text(text = "Einzelauswahl", style = TextStyles.contentStyle, color = Text_prime_light)
          }
        }
      }
      SpacerBetweenElements()
      pollViewModel.poll?.let { PollOptions(it.options, onCheckedChange = { pollViewModel.votedIndex = it }) }
      Spacer(modifier = Modifier.weight(1f))
      Column {
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors =
          ButtonDefaults.buttonColors(
            containerColor = Secondary, contentColor = Text_tertiary
          ),
          onClick = {
            // todo: ask if user is sure
            scope.launch {
              val voted = pollViewModel.putPollVote(0)
              if (!voted) {
                Toast.makeText(
                  navController.context, "Fehler beim Abstimmen", Toast.LENGTH_SHORT)
                  .show()
              } else {
                navController.navigate("umfrageAbgestimmt")
              }
            }
          },
        ) {
          Text(text = "Enthalten", color = Text_prime_light, style = TextStyles.contentStyle)
        }
        Button(
          modifier = Modifier.fillMaxWidth(),
          colors =
          ButtonDefaults.buttonColors(
            containerColor = Primary, contentColor = Background_secondary
          ),
          onClick = {
            // todo: ask if user is sure
            if (pollViewModel.votedIndex != -1) {
              scope.launch {
                val voted = pollViewModel.putPollVote(pollViewModel.votedIndex)
                if (!voted) {
                  Toast.makeText(
                    navController.context, "Fehler beim Abstimmen", Toast.LENGTH_SHORT)
                    .show()
                } else {
                  navController.navigate("umfrageAbgestimmt")
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