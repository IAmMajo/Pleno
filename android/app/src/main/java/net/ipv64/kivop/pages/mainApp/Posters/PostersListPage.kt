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
import net.ipv64.kivop.pages.Screen
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
                  image = postersViewModel.posterImages[poster.id],
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
