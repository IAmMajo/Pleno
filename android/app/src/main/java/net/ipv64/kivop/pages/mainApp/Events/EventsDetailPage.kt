package net.ipv64.kivop.pages.mainApp.Events

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.SitzungsCard

@Composable
fun EventsDetailPage(navController: NavController) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  
  //SitzungsCard()
}
