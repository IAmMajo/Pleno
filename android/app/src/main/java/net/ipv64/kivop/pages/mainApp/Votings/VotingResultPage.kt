// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.pages.mainApp.Votings

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
