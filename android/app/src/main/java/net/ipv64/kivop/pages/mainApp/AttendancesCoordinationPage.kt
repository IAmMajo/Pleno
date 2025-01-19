package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.AttendanceCoordinationList
import net.ipv64.kivop.components.LoggedUserAttendacneCard
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.models.viewModel.MeetingViewModel
import net.ipv64.kivop.models.viewModel.MeetingViewModelFactory
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_secondary

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun AttendancesCoordinationPage(
    navController: NavController,
    meetingId: String,
    meetingViewModel: MeetingViewModel = viewModel(factory = MeetingViewModelFactory(meetingId))
) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  // UI anzeigen
  Column(modifier = Modifier.background(Tertiary)) {
    SpacerTopBar()
    // Log.d("Sit", "$responseSitzungsCard")
    meetingViewModel.meeting?.let { SitzungsCard(it) }
    Spacer(Modifier.size(12.dp))
    Column(
        modifier =
            Modifier.background(
                    Background_prime, shape = RoundedCornerShape(topStart = 22.dp, topEnd = 22.dp))
                .padding(18.dp)) {
          var scope = rememberCoroutineScope()
          meetingViewModel.you?.let {
            LoggedUserAttendacneCard(
                it,
                meetingViewModel.meeting?.status,
                acceptClick = {
                  scope.launch { meetingViewModel.planAttendance(PlanAttendance.present) }
                },
                declineClick = {
                  scope.launch { meetingViewModel.planAttendance(PlanAttendance.absent) }
                })
          }
          SpacerBetweenElements()
          LazyColumn(
              modifier = Modifier.fillMaxWidth().fillMaxHeight(),
              verticalArrangement = Arrangement.spacedBy(12.dp)) {
                AttendanceCoordinationList(
                    title = "Present",
                    responses = meetingViewModel.presentList,
                    isVisible = meetingViewModel.isPresentVisible,
                    maxMembernumber = meetingViewModel.maxMembernumber,
                    background = Text_secondary,
                    onVisibilityToggle = { meetingViewModel.isPresentVisible = it })
                if (meetingViewModel.meeting?.status == MeetingStatus.scheduled ||
                    meetingViewModel.meeting?.status == MeetingStatus.inSession) {
                  AttendanceCoordinationList(
                      title = "Zugesagt",
                      responses = meetingViewModel.acceptedList,
                      isVisible = meetingViewModel.isAcceptedVisible,
                      maxMembernumber = meetingViewModel.maxMembernumber,
                      background = Color(color = 0xff1061DA),
                      onVisibilityToggle = { meetingViewModel.isAcceptedVisible = it })
                  AttendanceCoordinationList(
                      title = "Ausstehend",
                      responses = meetingViewModel.pendingList,
                      isVisible = meetingViewModel.isPendingVisible,
                      maxMembernumber = meetingViewModel.maxMembernumber,
                      onVisibilityToggle = { meetingViewModel.isPendingVisible = it })
                  AttendanceCoordinationList(
                      title = "Abgesagt",
                      responses = meetingViewModel.absentList,
                      isVisible = meetingViewModel.isAbsentVisible,
                      maxMembernumber = meetingViewModel.maxMembernumber,
                      background = Color(color = 0xffDA1043),
                      onVisibilityToggle = { meetingViewModel.isAbsentVisible = it })
                } else {
                  AttendanceCoordinationList(
                      title = "Abwesend",
                      responses = meetingViewModel.absentList,
                      isVisible = meetingViewModel.isAbsentVisible,
                      maxMembernumber = meetingViewModel.maxMembernumber,
                      background = Color(color = 0xffDA1043),
                      onVisibilityToggle = { meetingViewModel.isAbsentVisible = it })
                }
              }
          // TODO: FINISH THIS
          //      Text(text = "Votings")
          //      Column {
          //        meetingViewModel.votings.forEach({ voting ->
          //          var votingData =
          //            ItemListData(
          //              title = voting.question,
          //              id = voting.id.toString(),
          //              date = null,
          //              time = null,
          //              meetingStatus = "",
          //              timeRend = false,
          //              iconRend = false
          //            )
          //          try {
          //            votingData =
          //              ItemListData(
          //                title = voting.question,
          //                id = voting.id.toString(),
          //                date = voting.startedAt!!.toLocalDate(),
          //                time = null,
          //                meetingStatus = "",
          //                timeRend = false,
          //                iconRend = false
          //              )
          //          } catch (e: Exception) {
          //            Log.d("test", e.message.toString())
          //            Log.d("test", voting.question)
          //          }
          //
          // IconTextField(votingData.title,ImageVector.vectorResource(R.drawable.ic_pie_chart))
          //        })
          //      }
        }
  }
}
