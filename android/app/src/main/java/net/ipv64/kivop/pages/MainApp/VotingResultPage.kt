package net.ipv64.kivop.pages.MainApp

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.AbstimmungCard
import net.ipv64.kivop.components.PieChart
import net.ipv64.kivop.components.ResultCard
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultsDTO
import net.ipv64.kivop.models.GetVotingByID
import net.ipv64.kivop.models.GetVotingResultByID
import net.ipv64.kivop.models.VotingResults
import net.ipv64.kivop.ui.theme.Background_prime

@Composable
fun VotingResultPage(navController: NavController, votingID: String) {
  val coroutineScope = rememberCoroutineScope()
  var votingData by remember { mutableStateOf<GetVotingDTO?>(null) }
  var votings by remember { mutableStateOf<GetVotingResultsDTO?>(null) }
  var votingsCombined by remember { mutableStateOf<List<VotingResults>>(emptyList()) }

  LaunchedEffect(Unit) {
    coroutineScope.launch {
      votingData = GetVotingByID(navController.context, UUID.fromString(votingID))
      Log.d("voting", votingData?.options.toString())
      votings = GetVotingResultByID(navController.context, UUID.fromString(votingID))
      votingsCombined =
          votingData?.options!!.map { option ->
            val label = option.text
            val votes = votings?.results?.find { it.index == option.index }?.total?.toInt() ?: 0
            val percentage = votings?.results?.find { it.index == option.index }?.percentage ?: 0.0
            VotingResults(label, votes, percentage)
          }
    }
  }

  Column {
    if (votingData != null) {
      votingData!!.let { AbstimmungCard(title = it.description, date = it.startedAt!!) }
    }
    Spacer(modifier = Modifier.size(16.dp))
    //
    LazyColumn(
        modifier =
            Modifier.fillMaxWidth()
                .fillMaxHeight()
                .clip(RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                .background(Background_prime)
                .padding(18.dp)) {
          item {
            if (votingsCombined.isNotEmpty()) {
              PieChart(list = votingsCombined, explodeDistance = 15f)
              Spacer(modifier = Modifier.size(16.dp))
              ResultCard(votingsCombined)
            }
          }
        }
  }
}
