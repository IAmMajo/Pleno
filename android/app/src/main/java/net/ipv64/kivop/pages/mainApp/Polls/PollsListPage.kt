package net.ipv64.kivop.pages.mainApp.Polls

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
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
    LazyColumn(
      modifier = Modifier
        .weight(1f)
    ) {
      items(pollsListViewModel.pollsList) { poll ->
        if (poll != null) {
          ListenItem(
              poll,
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
    Box(
      modifier = Modifier
        .padding(top = 16.dp)
    ) {
      CustomButton(
        modifier = Modifier,
        text = "Erstellen",
        buttonStyle = primaryButtonStyle,
        onClick = { navController.navigate("umfrageErstellen") })
    }
  }
}
