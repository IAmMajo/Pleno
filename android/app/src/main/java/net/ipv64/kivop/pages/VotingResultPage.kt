package com.example.kivopandriod.pages

import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.size
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
import com.example.kivopandriod.services.stringToLocalDate
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.AbstimmungCard
import net.ipv64.kivop.components.ErgebnisCard
import net.ipv64.kivop.components.PieChart
import net.ipv64.kivop.moduls.GetVotingByID
import net.ipv64.kivop.moduls.GetVotingDTO
import net.ipv64.kivop.moduls.GetVotingResultByID
import net.ipv64.kivop.moduls.GetVotingResultsDTO
import net.ipv64.kivop.moduls.VotingResults

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
      AbstimmungCard(
          title = votingData!!.description,
          eventType = "Todo meeting name",
          date = stringToLocalDate(votingData!!.startedAt))
    }
    Spacer(modifier = Modifier.size(16.dp))
    //
    if (votingsCombined.isNotEmpty()) {
      PieChart(votingsCombined, 15f)
      Spacer(modifier = Modifier.size(16.dp))
      ErgebnisCard(votingsCombined)
    }
  }
}
