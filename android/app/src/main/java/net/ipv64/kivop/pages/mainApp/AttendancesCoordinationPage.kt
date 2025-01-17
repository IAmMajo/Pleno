package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
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
import net.ipv64.kivop.services.GetScreenHeight
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_red
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


  val screenHeightDp = GetScreenHeight()
  var columnHeightDp by remember { mutableStateOf(0.dp) }
  val density = LocalDensity.current

  val contentHeightDp by remember(screenHeightDp, columnHeightDp) {
    derivedStateOf { screenHeightDp - columnHeightDp}
  }


  var isDelayedVisible by remember { mutableStateOf(false) }

  LaunchedEffect(meetingViewModel.attendance.isNotEmpty()) {
    if (meetingViewModel.attendance.isNotEmpty()) {
      isDelayedVisible = true
    } else {
      isDelayedVisible = false
    }
  }


  // UI anzeigen
// Layout
  Column(modifier = Modifier.fillMaxSize().background(Tertiary)) {
    // Oberer Bereich
    Column(
      modifier = Modifier
        .fillMaxWidth()
        // .padding(start = 18.dp, end = 18.dp)
        .onGloballyPositioned { coordinates ->
          val newHeightDp = with(density) { coordinates.size.height.toDp() }
          if (newHeightDp != columnHeightDp) {
            columnHeightDp = newHeightDp
          }
        }
    ) {
      SpacerTopBar()
      meetingViewModel.meeting?.let { SitzungsCard(it) }
    }




    // Hauptinhalt
    val offsetY by animateDpAsState(
      targetValue = if (isDelayedVisible) 0.dp else contentHeightDp,
      animationSpec =  tween(durationMillis = 500)
    )

    Column(
      modifier = Modifier
        .offset(y = offsetY)
        .weight(1f)
        .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
        .background(Background_prime)
        .padding(top = 18.dp, start = 18.dp, end = 18.dp)
    ) {
      var scope = rememberCoroutineScope()
      meetingViewModel.you?.let {
        LoggedUserAttendacneCard(
          it,
          meetingViewModel.meeting?.status,
          acceptClick = {
            scope.launch {
              meetingViewModel.planAttendance(PlanAttendance.present)
            }
          },
          declineClick = {
            scope.launch {
              meetingViewModel.planAttendance(PlanAttendance.absent)
            }
          }
        )
      }
      SpacerBetweenElements()

      LazyColumn(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
      ) {
        AttendanceCoordinationList(
          title = "Present",
          responses = meetingViewModel.presentList,
          isVisible = meetingViewModel.isPresentVisible,
          maxMembernumber = meetingViewModel.maxMembernumber,
          background = Text_secondary,
          onVisibilityToggle = { meetingViewModel.isPresentVisible = it }
        )

        if (meetingViewModel.meeting?.status == MeetingStatus.scheduled ||
          meetingViewModel.meeting?.status == MeetingStatus.inSession
        ) {
          AttendanceCoordinationList(
            title = "Zugesagt",
            responses = meetingViewModel.acceptedList,
            isVisible = meetingViewModel.isAcceptedVisible,
            maxMembernumber = meetingViewModel.maxMembernumber,
            background = Signal_blue,
            onVisibilityToggle = { meetingViewModel.isAcceptedVisible = it }
          )
          AttendanceCoordinationList(
            title = "Ausstehend",
            responses = meetingViewModel.pendingList,
            isVisible = meetingViewModel.isPendingVisible,
            maxMembernumber = meetingViewModel.maxMembernumber,
            onVisibilityToggle = { meetingViewModel.isPendingVisible = it }
          )
        }

        AttendanceCoordinationList(
          title = if (meetingViewModel.meeting?.status == MeetingStatus.scheduled ||
            meetingViewModel.meeting?.status == MeetingStatus.inSession
          ) "Abgesagt" else "Abwesend",
          responses = meetingViewModel.absentList,
          isVisible = meetingViewModel.isAbsentVisible,
          maxMembernumber = meetingViewModel.maxMembernumber,
          background = Signal_red,
          onVisibilityToggle = { meetingViewModel.isAbsentVisible = it }
        )
      }
    }
  }






//      TODO: FINISH THIS
//      Text(text = "Votings")
//      Column {
//        meetingViewModel.votings.forEach { voting ->
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
//          IconTextField(votingData.title, ImageVector.vectorResource(R.drawable.ic_pie_chart))
//        }
//      }
}
  

