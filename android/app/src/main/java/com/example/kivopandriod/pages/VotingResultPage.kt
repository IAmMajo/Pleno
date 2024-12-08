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
import com.example.kivopandriod.components.AbstimmungCard
import com.example.kivopandriod.components.ErgebnisCard
import com.example.kivopandriod.components.PieChart
import com.example.kivopandriod.moduls.GetVotingDTO
import com.example.kivopandriod.moduls.GetVotingOptionDTO
import com.example.kivopandriod.moduls.GetVotingResultDTO
import com.example.kivopandriod.moduls.GetVotingResultsDTO
import com.example.kivopandriod.moduls.VotingResults
import com.example.kivopandriod.services.api.GetVotingByID
import com.example.kivopandriod.services.api.GetVotingResultByID
import com.example.kivopandriod.services.stringToDate
import com.example.kivopandriod.services.stringToLocalDate
import kotlinx.coroutines.launch
import java.time.LocalDate
import java.util.UUID

@Composable
fun VotingResultPage(navController: NavController, votingID: String){
    val coroutineScope = rememberCoroutineScope()
    var votingData by remember { mutableStateOf<GetVotingDTO?>(null) }
    var votings by remember { mutableStateOf<GetVotingResultsDTO?>(null) }
    var votingsCombined by remember { mutableStateOf<List<VotingResults>>(emptyList()) }

    LaunchedEffect(Unit) {
        coroutineScope.launch {
            votingData = GetVotingByID(navController.context, UUID.fromString(votingID))
            Log.d("voting", votingData?.options.toString())
            votings = GetVotingResultByID(navController.context, UUID.fromString(votingID))
            votingsCombined = votingData?.options!!.map { option ->
                val label = option.text
                val votes = votings?.results?.find { it.index == option.index }?.total?.toInt() ?: 0
                val percentage = votings?.results?.find { it.index == option.index }?.percentage ?: 0.0
                VotingResults(label, votes, percentage)
            }
        }
    }

    Column {
        if (votingData != null){
            AbstimmungCard(
                title = votingData!!.description,
                eventType = "Todo meeting name",
                date = stringToLocalDate(votingData!!.startedAt)
            )
        }
        Spacer(modifier = Modifier.size(16.dp))
        //
        if (votingsCombined.isNotEmpty()){
            PieChart(votingsCombined, 15f)
            Spacer(modifier = Modifier.size(16.dp))
            ErgebnisCard(votingsCombined)
        }
    }



}