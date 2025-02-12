package net.ipv64.kivop.pages.mainApp.Carpool

import GenerateTabs
import android.util.Log
import androidx.activity.compose.BackHandler
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
import net.ipv64.kivop.components.CarpoolCard
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.models.viewModel.CarpoolingListViewModel

@Composable
fun CarpoolingList(
    navController: NavController,
    carpoolingListViewModel: CarpoolingListViewModel = viewModel()
) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  LaunchedEffect(Unit) { carpoolingListViewModel.fetchCarpoolingList() }
  Column(modifier = Modifier.padding(18.dp)) {
    SpacerTopBar()
    val tabs = listOf("Fahrten", "Deine Fahrten")
    val tabContents: List<@Composable () -> Unit> =
        listOf(
            {
              LazyColumn(modifier = Modifier.weight(1f)) {
                items(carpoolingListViewModel.otherRidesList) { carpool ->
                  if (carpool != null) {
                    CarpoolCard(
                        carpool = carpool,
                        onClick = { navController.navigate("carpool/${carpool.id}") })
                    SpacerBetweenElements()
                  }
                }
              }
            },
            {
              LazyColumn(modifier = Modifier.weight(1f)) {
                items(carpoolingListViewModel.driverRidesList) { carpool ->
                  if (carpool != null) {
                    CarpoolCard(
                        carpool = carpool,
                        onClick = { navController.navigate("carpool/${carpool.id}") })
                    SpacerBetweenElements()
                  }
                }
              }
            })
    GenerateTabs(tabs = tabs, tabContents = tabContents)
    Spacer(modifier = Modifier.weight(1f))
    CustomButton(
        modifier = Modifier,
        text = "Erstellen",
        buttonStyle = primaryButtonStyle,
        onClick = { navController.navigate("createCarpool") })
  }
}
