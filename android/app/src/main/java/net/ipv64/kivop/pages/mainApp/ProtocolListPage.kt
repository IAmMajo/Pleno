package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.Markdown
import net.ipv64.kivop.models.viewModel.ProtocolViewModel
import net.ipv64.kivop.models.viewModel.ProtocolViewModelFactory

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProtocolListPage(navController: NavController, meetingId: String, protocolLang: String) {
  val protocolViewModel: ProtocolViewModel = viewModel(factory = ProtocolViewModelFactory(meetingId,protocolLang))
  protocolViewModel.protocol

  Column(modifier = Modifier.fillMaxSize()) {
    protocolViewModel.protocol?.votingResultsAppendix?.let {
      Markdown(
        markdown = it
      )
    }
  }
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
 
  Text(text = "ProtocolListPage")

 
  
}
