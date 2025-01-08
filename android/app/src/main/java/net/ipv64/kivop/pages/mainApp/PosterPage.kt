package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.Screen
import net.ipv64.kivop.components.PosterInfoCard
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import java.util.UUID

@Composable
fun PosterPage(navController: NavController) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  Column(
    modifier = Modifier.padding(18.dp)
  ) {
    SpacerTopBar()
    
  }
}
