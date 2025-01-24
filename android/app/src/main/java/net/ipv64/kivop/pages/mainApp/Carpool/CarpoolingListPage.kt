package net.ipv64.kivop.pages.mainApp.Carpool

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
import net.ipv64.kivop.models.viewModel.CarpoolingListViewModel

@Composable
fun CarpoolingList(
    navController: NavController,
    carpoolingListViewModel: CarpoolingListViewModel = viewModel()
) {
  val carpoolingList = carpoolingListViewModel.CarpoolingList
  
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  LaunchedEffect(Unit) { 
    carpoolingListViewModel.fetchCarpoolingList()
  }
  Column(modifier = Modifier.padding(18.dp)) {
    SpacerTopBar()
    LazyColumn() {
      items(carpoolingList) { carpool ->
        if (carpool != null) {
          CarpoolCard(
              carpool = carpool, onClick = { navController.navigate("carpool/${carpool.id}") })
          SpacerBetweenElements()
        }
      }
    }
    Spacer(modifier = Modifier.weight(1f))
    CustomButton(
      modifier = Modifier,
      text = "Erstellen",
      onClick = { navController.navigate("createCarpool") }
    )
  }
}
