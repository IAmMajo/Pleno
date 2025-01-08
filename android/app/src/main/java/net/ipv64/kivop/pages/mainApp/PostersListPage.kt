package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.Screen
import net.ipv64.kivop.components.PosterInfoCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.models.PosterNeedDTO
import net.ipv64.kivop.models.viewModel.MeetingsViewModel
import net.ipv64.kivop.models.viewModel.PostersViewModel
import java.util.UUID

@Composable
fun PostersListPage(navController: NavController) {
  val postersViewModel = viewModel<PostersViewModel>()
  
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(
    modifier = Modifier.padding(18.dp)
  ) {
    SpacerTopBar()
    LazyColumn {
      items(postersViewModel.posters) { poster ->
        PosterInfoCard(
          poster = poster!!
        )
        SpacerBetweenElements()
      }
    }
  }
}
