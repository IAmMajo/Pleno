package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProtocolListPage(navController: NavController, meetingId: String, protocollang: String) {
  //val protocol: ProtocolViewModel = viewModel(factory = ProtocolViewModelFactory(protocolId))
  
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
 
  Text(text = "ProtocolListPage")

 
  
}
