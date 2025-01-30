package net.ipv64.kivop.pages.mainApp.Posters

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.Screen
import net.ipv64.kivop.components.PosterInfoCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.models.viewModel.PostersViewModel
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary

@Composable
fun PostersListPage(navController: NavController) {
  val postersViewModel = viewModel<PostersViewModel>()

  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(modifier = Modifier.padding(18.dp), horizontalAlignment = Alignment.CenterHorizontally) {
    SpacerTopBar()

    LazyColumn {
      if (postersViewModel.isLoading) {
        item {
          CircularProgressIndicator(
              modifier = Modifier.size(50.dp),
              trackColor = Background_secondary,
              color = Primary,
              strokeWidth = 5.dp,
              strokeCap = androidx.compose.ui.graphics.StrokeCap.Round)
        }
      } else {
        if (postersViewModel.posters.isNotEmpty()) {
          items(postersViewModel.posters) { poster ->
            if (poster != null) {
              PosterInfoCard(
                  poster = poster,
                  summary = postersViewModel.posterSummaries[poster.id],
                  onPosterClick = { navController.navigate(Screen.Poster.rout + "/${poster.id}") })
              SpacerBetweenElements()
            }
          }
        }
      }
    }
  }
}
