// package net.ipv64.kivop.pages.mainApp
//
// import android.util.Log
// import androidx.activity.compose.BackHandler
// import androidx.compose.foundation.layout.Column
// import androidx.compose.foundation.layout.Spacer
// import androidx.compose.foundation.layout.fillMaxSize
// import androidx.compose.foundation.layout.size
// import androidx.compose.foundation.lazy.LazyColumn
// import androidx.compose.foundation.lazy.items
// import androidx.compose.material3.Text
// import androidx.compose.runtime.Composable
// import androidx.compose.runtime.LaunchedEffect
// import androidx.compose.runtime.getValue
// import androidx.compose.runtime.mutableStateOf
// import androidx.compose.runtime.remember
// import androidx.compose.runtime.setValue
// import androidx.compose.ui.Modifier
// import androidx.compose.ui.unit.dp
// import androidx.navigation.NavController
// import java.util.UUID
// import net.ipv64.kivop.BackPressed.isBackPressed
// import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
// import net.ipv64.kivop.models.GetVotings
// import net.ipv64.kivop.models.ItemListData
// import net.ipv64.kivop.models.getMyVote
//
// @Composable
// fun VotingsListPage(navController: NavController) {
//  BackHandler {
//    isBackPressed = navController.popBackStack()
//    Log.i("BackHandler", "BackHandler: $isBackPressed")
//  }
//  var votings by remember { mutableStateOf<List<GetVotingDTO>>(emptyList()) }
//
//  LaunchedEffect(Unit) {
//    val result = GetVotings(navController.context)
//    votings = result
//  }
//
//  Column(modifier = Modifier.fillMaxSize()) {
//    Text(text = "Votings")
//    LazyColumn() {
//      items(votings) { voting ->
//        var votingData =
//            ItemListData(
//                title = voting.question,
//                id = voting.id.toString(),
//                date = null,
//                time = null,
//                meetingStatus = "",
//                timeRend = false,
//                iconRend = false)
//        try {
//          votingData =
//              ItemListData(
//                  title = voting.question,
//                  id = voting.id.toString(),
//                  date = voting.startedAt!!.toLocalDate(),
//                  time = null,
//                  meetingStatus = "",
//                  timeRend = false,
//                  iconRend = false)
//        } catch (e: Exception) {
//          Log.d("test", e.message.toString())
//          Log.d("test", voting.question)
//        }
//        // Todo: Brauchen die Page nicht mehr
//        Spacer(modifier = Modifier.size(8.dp))
//      }
//    }
//  }
// }
//
// suspend fun voted(id: UUID): Boolean {
//  val myVote = getMyVote(id)
//  return myVote != null
// }
