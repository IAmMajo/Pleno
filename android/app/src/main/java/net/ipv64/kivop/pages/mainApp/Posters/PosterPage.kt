package net.ipv64.kivop.pages.mainApp.Posters

import android.util.Log
import androidx.activity.compose.BackHandler
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
import net.ipv64.kivop.components.PosterInfoCard
import net.ipv64.kivop.components.PosterLocationCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.PosterViewModel
import net.ipv64.kivop.models.viewModel.PosterViewModelFactory
import net.ipv64.kivop.Screen
import net.ipv64.kivop.models.viewModel.PosterDetailedViewModelFactory

@Composable
fun PosterPage(navController: NavController, posterID: String) {
  val posterViewModel: PosterViewModel = viewModel(factory = PosterViewModelFactory(posterID))
  // Fetch addresses for each location
  LaunchedEffect(posterViewModel.posterPositions) {
    posterViewModel.posterPositions.let { posters ->
      val newAddresses =
        posters.associate { poster ->
          // only fetch when the poster address isnt already in the lib
          if (posterViewModel.posterAddresses.containsKey(poster.id)) {
            poster.id to posterViewModel.posterAddresses[poster.id].toString()
          } else {
            poster.id to
              posterViewModel
                .fetchAddress(poster.latitude, poster.longitude)
                .toString()
          }
        }
      posterViewModel.posterAddresses = newAddresses
    }
  }
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(
    modifier = Modifier.padding(18.dp)
  ) {
    SpacerTopBar()
    
    //Displays main information
    posterViewModel.poster?.let {
      posterViewModel.posterSummary?.let { it1 ->
        PosterInfoCard(
          it,
          it1,
          clickable = false,
          showMaps = true)
      }
    }
        
    //Displays each location
    LazyColumn { 
      items(posterViewModel.posterPositions) { poster ->
        PosterLocationCard(
          poster,
          posterViewModel.posterAddresses[poster.id],
          onClick = { navController.navigate(Screen.PosterDetail.rout + "/${poster.posterId}/${poster.id}")})
        SpacerBetweenElements(8.dp)
      }
    }
  }
}
