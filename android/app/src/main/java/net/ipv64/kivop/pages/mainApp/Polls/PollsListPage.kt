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

package net.ipv64.kivop.pages.mainApp.Polls

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.ListenItem
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.PollsListViewModel

@Composable
fun PollsListPage(navController: NavController) {
  val pollsListViewModel: PollsListViewModel = viewModel()
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  LaunchedEffect(Unit) { pollsListViewModel.fetchPoll() }
  // content
  Column(modifier = Modifier.padding(22.dp)) {
    SpacerTopBar()
    LazyColumn(modifier = Modifier.weight(1f)) {
      items(pollsListViewModel.pollsList) { poll ->
        if (poll != null) {
          ListenItem(
              poll,
              // Navigiert zur richtigen Seite basierend auf dem Status der Umfrage
              onClick = {
                if (poll.isOpen && !poll.iVoted) {
                  navController.navigate("umfrage/${poll.id}")
                } else if (poll.isOpen && poll.iVoted) {
                  navController.navigate("umfrageAbgestimmt")
                } else {
                  navController.navigate("umfrageErgebnis/${poll.id}")
                }
              })
          SpacerBetweenElements(8.dp)
        }
      }
    }
    Box(modifier = Modifier.padding(top = 16.dp)) {
      CustomButton(
          modifier = Modifier,
          text = "Erstellen",
          buttonStyle = primaryButtonStyle,
          onClick = { navController.navigate("umfrageErstellen") })
    }
  }
}
