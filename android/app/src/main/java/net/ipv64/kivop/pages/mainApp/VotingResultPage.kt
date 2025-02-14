package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
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
import androidx.compose.runtime.getValue
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.AbstimmungCard
import net.ipv64.kivop.components.PieChart
import net.ipv64.kivop.components.ResultCard
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.VotingResultViewModel
import net.ipv64.kivop.models.viewModel.VotingResultViewModelFactory
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary

@Composable
fun VotingResultPage(navController: NavController, votingID: String) {
  val votingResultViewModel: VotingResultViewModel =
      viewModel(factory = VotingResultViewModelFactory(votingID))
  val previousBackStackEntry = navController.previousBackStackEntry
  BackHandler {
    if (previousBackStackEntry != null) {
      if (previousBackStackEntry.destination.route == "abgestimmt/{votingID}") {
        // Go back three times to land back on the meeting page if last page was alreadyVotedPage
        isBackPressed = navController.popBackStack()
        navController.popBackStack()
        navController.popBackStack()
        Log.i("BackHandler", "BackHandler: $isBackPressed")
      } else {
        isBackPressed = navController.popBackStack()
      }
    }
  }
  
  Column(modifier = Modifier.background(Primary)) {
    SpacerTopBar()
    if (votingResultViewModel.votingData != null) {
      votingResultViewModel.votingData!!.let {
        AbstimmungCard(title = it.description, date = it.startedAt!!)
      }
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
            votingResultViewModel.votingResults?.let {
              //Ergebnisse der Umfrage in einem Kuchendiagram
              PieChart(votingResults = it, explodeDistance = 15f)
            }
            Spacer(modifier = Modifier.size(16.dp))
            if (votingResultViewModel.votingResults != null &&
                votingResultViewModel.votingData != null) {
              //Ergebnisse der Umfrage
              ResultCard(votingResultViewModel.votingResults!!, votingResultViewModel.votingData!!)
            }
          }
        }
  }
}
