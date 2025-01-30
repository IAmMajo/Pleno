package net.ipv64.kivop.pages.mainApp

import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.R
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.VotingViewModel
import net.ipv64.kivop.models.viewModel.VotingViewModelFactory
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun AlreadyVoted(navController: NavController, votingID: String) {
  val viewModel: VotingViewModel =
      viewModel(factory = VotingViewModelFactory(votingID)) // Use factory if needed
  val votingStatus by viewModel.votingStatus.collectAsState()
  val votingResults by viewModel.votingResults.collectAsState()

  LaunchedEffect(Unit) { viewModel.connectWebSocket() }

  BackHandler {
    val previousBackStackEntry = navController.previousBackStackEntry
    if (previousBackStackEntry != null) {
      if (previousBackStackEntry.destination.route.toString() == "abstimmen/{votingID}") {
        navController.popBackStack()
        navController.popBackStack()
      } else {
        navController.popBackStack()
      }
    }
  }
  Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
    var navigated = remember { mutableStateOf(false) }
    if (votingResults && !navigated.value) {
      navController.navigate("abstimmung/$votingID")
      navigated.value = true
    }
    Column(
        modifier = Modifier.background(Background_prime).fillMaxHeight(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center) {
          Spacer(Modifier.weight(0.5f))
          Icon(
              modifier = Modifier.size(300.dp),
              tint = Text_prime,
              painter = painterResource(id = R.drawable.ic_clock),
              contentDescription = "Icon Clock")
          Text(
              text = "Die Abstimmung ist noch im Gange...",
              color = Text_prime,
              textAlign = TextAlign.Center,
              style = TextStyles.headingStyle)
          SpacerBetweenElements(20.dp)
          Box(
              modifier =
                  Modifier.width(250.dp)
                      .height(40.dp)
                      .background(Primary_20, shape = RoundedCornerShape(8.dp))) {
                Row(
                    modifier = Modifier.fillMaxSize(),
                    horizontalArrangement = Arrangement.Center,
                    verticalAlignment = Alignment.CenterVertically) {
                      Icon(
                          modifier = Modifier.size(30.dp),
                          tint = Text_prime,
                          painter = painterResource(id = R.drawable.ic_groups),
                          contentDescription = "Icon Clock")
                      SpacerBetweenElements()
                      Text(
                          text = "$votingStatus Stimmen abgegeben",
                          color = Primary,
                          style = TextStyles.largeContentStyle)
                    }
              }
          Spacer(Modifier.weight(1f))
          CustomButton(
              text = "Zurück",
              onClick = {
                val previousBackStackEntry = navController.previousBackStackEntry
                if (previousBackStackEntry != null) {
                  // only go back two steps when last Page was Vote Page
                  if (previousBackStackEntry.destination.route.toString() ==
                      "abstimmen/{votingID}") {
                    navController.popBackStack()
                    navController.popBackStack()
                  } else {
                    navController.popBackStack()
                  }
                }
              },
              modifier = Modifier,
              buttonStyle = primaryButtonStyle)
        }
  }
}
