package net.ipv64.kivop.pages.mainApp.Carpool.onBoardingCreateRide

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.pager.PagerState
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import java.time.format.DateTimeFormatter
import kotlinx.coroutines.launch
import net.ipv64.kivop.R
import net.ipv64.kivop.components.IconTextField
import net.ipv64.kivop.components.Route
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.CreateSpecialRideViewModel
import net.ipv64.kivop.ui.customRoundedTop
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime_light

@Composable
fun CreateRide04Page(
    navController: NavController,
    pagerState: PagerState,
    createSpecialRideViewModel: CreateSpecialRideViewModel = viewModel()
) {
  val context = LocalContext.current
  if (pagerState.currentPage == 4) {
    createSpecialRideViewModel.done = true
  }
  Column(
      modifier = Modifier.fillMaxWidth().fillMaxHeight().background(Primary),
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.Center) {
        SpacerTopBar()
        Text(
            text = "Check Out", // TODO: replace text with getString
            style = TextStyles.headingStyle,
            color = Text_prime_light)
        Column(
            modifier = Modifier.fillMaxWidth().weight(4f).background(Primary).padding(18.dp),
            horizontalAlignment = Alignment.CenterHorizontally) {
              IconTextField(
                  icon = ImageVector.vectorResource(R.drawable.ic_place),
                  text = createSpecialRideViewModel.name,
                  subText = createSpecialRideViewModel.description,
                  textStyle = TextStyles.largeContentStyle,
              )
              SpacerBetweenElements(8.dp)
              IconTextField(
                  icon = ImageVector.vectorResource(R.drawable.ic_calendar),
                  text =
                      createSpecialRideViewModel.starts.format(
                          DateTimeFormatter.ofPattern("dd.MM.yyyy | HH:mm")) +
                          " - " +
                          createSpecialRideViewModel.ends.format(
                              DateTimeFormatter.ofPattern("dd.MM.yyyy | HH:mm")),
                  textStyle = TextStyles.largeContentStyle,
              )
              SpacerBetweenElements(8.dp)
              Route(
                  createSpecialRideViewModel.startAddress,
                  createSpecialRideViewModel.destinationAddress)
              SpacerBetweenElements(8.dp)
              IconTextField(
                  text = createSpecialRideViewModel.emptySeats.toString() + " freie Sitze",
                  textStyle = TextStyles.largeContentStyle,
              )
            }
        Column(
            modifier =
                Modifier.fillMaxWidth()
                    .weight(1f)
                    .background(Background_prime)
                    .customRoundedTop(Background_prime, heightPercent = 40, widthPercent = 30)
                    .padding(18.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Bottom) {
              val coroutineScope = rememberCoroutineScope()
              Button(
                  modifier = Modifier.fillMaxWidth(),
                  onClick = {
                    coroutineScope.launch {
                      pagerState.animateScrollToPage(pagerState.currentPage - 1)
                    }
                  },
                  colors =
                      ButtonDefaults.buttonColors(
                          containerColor = Color.Transparent, contentColor = Primary)) {
                    if (createSpecialRideViewModel.done) {
                      Text(text = "Zurück", style = TextStyles.contentStyle, color = Primary)
                    }
                  }
              Button(
                  modifier = Modifier.fillMaxWidth(),
                  onClick = {
                    coroutineScope.launch {
                      if (createSpecialRideViewModel.postRide()) {
                        navController.popBackStack()
                      } else {
                        Toast.makeText(context, "Es ist ein Fehler aufgetreten", Toast.LENGTH_SHORT)
                            .show()
                      }
                    }
                  },
                  colors =
                      ButtonDefaults.buttonColors(
                          containerColor = Primary, contentColor = Background_prime)) {
                    Text(
                        text = "Erstellen",
                        style = TextStyles.contentStyle,
                        color = Text_prime_light)
                  }
            }
      }
}
