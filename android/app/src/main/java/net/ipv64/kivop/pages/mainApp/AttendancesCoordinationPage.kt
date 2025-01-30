package net.ipv64.kivop.pages.mainApp

import AgendaCard
import android.util.Log
import android.widget.Toast
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.IconTextField
import net.ipv64.kivop.components.ListenItem
import net.ipv64.kivop.components.LoggedUserAttendacneCard
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.models.ItemListData
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.models.viewModel.MeetingViewModel
import net.ipv64.kivop.models.viewModel.MeetingViewModelFactory
import net.ipv64.kivop.services.GetScreenHeight
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Tertiary

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
  val context = LocalContext.current
  val screenHeightDp = GetScreenHeight()
  var columnHeightDp by remember { mutableStateOf(0.dp) }
  val density = LocalDensity.current

  val contentHeightDp by
  remember(screenHeightDp, columnHeightDp) {
    derivedStateOf { screenHeightDp - columnHeightDp }
  }

  var isDelayedVisible by remember { mutableStateOf(false) }

  LaunchedEffect(Unit) {
    meetingViewModel.fetchMeeting()
    meetingViewModel.fetchAttendance()
    meetingViewModel.fetchVotings()
    meetingViewModel.fetchProtocol()
  }

  LaunchedEffect(meetingViewModel.attendance.isNotEmpty()) {
    if (meetingViewModel.attendance.isNotEmpty()) {
      isDelayedVisible = true
    } else {
      isDelayedVisible = false
    }
  }

  // UI anzeigen
  // Layout
  Column(modifier = Modifier
    .fillMaxSize()
    .background(Tertiary)) {
    // Oberer Bereich
    Column(
      modifier =
      Modifier
        .fillMaxWidth()
        // .padding(start = 18.dp, end = 18.dp)
        .onGloballyPositioned { coordinates ->
          val newHeightDp = with(density) { coordinates.size.height.toDp() }
          if (newHeightDp != columnHeightDp) {
            columnHeightDp = newHeightDp
          }
        }) {
      SpacerTopBar()
      meetingViewModel.meeting?.let { SitzungsCard(it) }
    }

    var scope = rememberCoroutineScope()

    // Hauptinhalt
    val offsetY by
    animateDpAsState(
      targetValue = if (isDelayedVisible) 0.dp else contentHeightDp,
      animationSpec = tween(durationMillis = 500)
    )

    Column(
      modifier =
      Modifier
        .offset(y = offsetY)
        .fillMaxHeight()
        .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
        .background(Background_prime)
        .padding(top = 18.dp, start = 18.dp, end = 18.dp),
    ) {
      LazyColumn(
        verticalArrangement = Arrangement.spacedBy(12.dp), modifier = Modifier.fillMaxWidth()
      ) {
        item {
          meetingViewModel.you?.let {
            LoggedUserAttendacneCard(
              it,
              meetingViewModel.meeting?.status,
              acceptClick = {
                scope.launch { meetingViewModel.planAttendance(PlanAttendance.present) }
              },
              declineClick = {
                scope.launch { meetingViewModel.planAttendance(PlanAttendance.absent) }
              },
              maxMembernumber = meetingViewModel.maxMembernumber,
              acceptedORpresentListcound =
              if (meetingViewModel.meeting?.status == MeetingStatus.scheduled) {
                meetingViewModel.acceptedListcound
              } else {
                meetingViewModel.presentListcount
              },
              meetingViewModel = meetingViewModel
            )
          }
          SpacerBetweenElements()
        }
        item {
          Text(text = "Agenda")
          SpacerBetweenElements()
          meetingViewModel.meeting?.let {
            AgendaCard(name = meetingViewModel.meeting!!.name, content = it.description)
          }
          SpacerBetweenElements()
        }

        item {
          if (meetingViewModel.votings.isNotEmpty()) {
            Text(text = "Votings")
            SpacerBetweenElements()
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
              meetingViewModel.votings.forEach { voting ->
                var votingData =
                  ItemListData(
                    title = voting.question,
                    id = voting.id.toString(),
                    date = null,
                    time = null,
                    meetingStatus = "",
                    timeRend = false,
                    iconRend = false
                  )
                try {
                  votingData =
                    ItemListData(
                      title = voting.question,
                      id = voting.id.toString(),
                      date = voting.startedAt!!.toLocalDate(),
                      time = null,
                      meetingStatus = "",
                      timeRend = false,
                      iconRend = false
                    )
                } catch (e: Exception) {
                  Log.d("test", e.message.toString())
                  Log.d("test", voting.question)
                }
                IconTextField(
                  text = votingData.title,
                  icon = ImageVector.vectorResource(R.drawable.ic_pie_chart),
                  onClick = {
                    if (meetingViewModel.meeting!!.myAttendanceStatus == null) {
                      Toast.makeText(
                        context,
                        "Du bist nicht bei der Sitzung angemeldet",
                        Toast.LENGTH_SHORT
                      ).show()
                    } else {
                      if (voting.isOpen) {
                        if (voting.iVoted && voting.closedAt == null) {
                          navController.navigate("abgestimmt/${voting.id}")
                        } else if (voting.iVoted) {
                          navController.navigate("abstimmung/${voting.id}")
                        } else {
                          navController.navigate("abstimmen/${voting.id}")
                        }
                      } else if (voting.closedAt != null) {
                        navController.navigate("abstimmung/${voting.id}")
                      } else {
                        Toast.makeText(
                          context,
                          "Die Abstimmung ist noch nicht geöffnet",
                          Toast.LENGTH_SHORT
                        ).show()
                      }
                    }
                  })
              }
            }
            SpacerBetweenElements()
          }
        }

        item {
          if (meetingViewModel.meeting?.status != MeetingStatus.scheduled) {
            Text(text = "Protokoll")
            SpacerBetweenElements()
            Log.d("Deteil", "${meetingViewModel.protocols}")
            meetingViewModel.meeting?.let {
              ListenItem(
                itemListData = it,
                onClick = { navController.navigate("protokolleDetail/${it.id}") },
                isProtokoll = true
              )
            }
            SpacerBetweenElements()
          }
        }
      }
    }
  }
}
