package net.ipv64.kivop.pages.mainApp.Posters

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.Screen
import net.ipv64.kivop.components.PosterInfoCard
import net.ipv64.kivop.components.PosterLocationCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.models.viewModel.PosterViewModel
import net.ipv64.kivop.models.viewModel.PosterViewModelFactory
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun PosterPage(navController: NavController, posterID: String, userViewModel: UserViewModel) {
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
                  posterViewModel.fetchAddress(poster.latitude, poster.longitude).toString()
            }
          }
      posterViewModel.posterAddresses = newAddresses
    }
  }
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(modifier = Modifier.padding(18.dp)) {
    SpacerTopBar()

    // Displays main information
    posterViewModel.poster?.let { poster ->
      posterViewModel.posterSummary?.let { summary ->
        PosterInfoCard(
          poster =poster,
          image = posterViewModel.posterImage,
          summary = summary,
          clickable = false, 
          showMaps = true)
      }
    }
    SpacerBetweenElements()
    // Displays each location
    if (posterViewModel.posterPositions.isEmpty()) {
      Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator(
            modifier = Modifier.size(50.dp),
            trackColor = Background_secondary,
            color = Primary,
            strokeWidth = 5.dp,
            strokeCap = StrokeCap.Round)
      }
    }
    LazyColumn {
      posterViewModel.groupedPosters.forEach { (status, items) ->
        // Section Header (Sticky Header Alternative)
        item {
          // Heading string
          val statusLabels =
              mapOf(
                  PosterPositionStatus.toHang to "Offen",
                  PosterPositionStatus.hangs to "Aufgehangen",
                  PosterPositionStatus.overdue to "Überfällig",
                  PosterPositionStatus.damaged to "Beschädigt",
                  PosterPositionStatus.takenDown to "Abgehangen")

          Text(
              text = statusLabels[status] ?: status.toString(),
              style = TextStyles.subHeadingStyle,
              color = Text_prime,
          )
          SpacerBetweenElements(8.dp)
        }

        // Poster Items under the Header
        items(items) { poster ->
          PosterLocationCard(
              poster=poster,
              image = posterViewModel.posterPositionsImages[poster.id],
              userViewModel = userViewModel,
              address =  posterViewModel.posterAddresses[poster.id],
              onClick = {
                navController.navigate(
                    Screen.PosterDetail.rout + "/${poster.posterId}/${poster.id}")
              })
          SpacerBetweenElements(8.dp)
        }
      }
    }
  }
}
