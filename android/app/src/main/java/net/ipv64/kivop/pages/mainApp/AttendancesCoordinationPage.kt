
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
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
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.AttendanceCoordinationList
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.services.GetScreenHeight
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun AttendancesCoordinationPage(navController: NavController, meetingId: String) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  var responses by remember { mutableStateOf<List<ResponseItem>>(emptyList()) }
  var responseSitzungsCard by remember { mutableStateOf<GetMeetingDTO?>(null) }
  val screenHeightDp = GetScreenHeight()
  var columnHeightDp by remember { mutableStateOf(0.dp) }
  val density = LocalDensity.current
  
  val pendingList = responses.filter { it.status == null }
  val presentList = responses.filter { it.status == AttendanceStatus.present }
  val absentList = responses.filter { it.status == AttendanceStatus.absent }
  val acceptedList = responses.filter { it.status == AttendanceStatus.accepted }
  val maxMembernumber = responses.size

  var isPendingVisible by remember { mutableStateOf(true) }
  var isPresentVisible by remember { mutableStateOf(true) }
  var isAbsentVisible by remember { mutableStateOf(true) }
  var isAcceptedVisible by remember { mutableStateOf(true) }



  // API-Anfragen
  LaunchedEffect(meetingId) {
    responseSitzungsCard = getMeetingByID(meetingId)
    responses = getAttendances(meetingId).map { response ->
      ResponseItem(name = response.identity.name, status = response.status)
    }
  }

  val contentHeightDp by remember(screenHeightDp, columnHeightDp) {
    derivedStateOf { screenHeightDp - columnHeightDp}
  }

  var isDelayedVisible by remember { mutableStateOf(false) }

  LaunchedEffect(responses.isNotEmpty()) {
    if (responses.isNotEmpty()) {
      isDelayedVisible = true
    } else {
      isDelayedVisible = false
    }
  }

  // Layout
  Column(modifier = Modifier.fillMaxSize().background(Primary)) {
    // Oberer Bereich
    Column(
      modifier = Modifier
        .fillMaxWidth()
        .weight(0.5f)
       // .padding(start = 18.dp, end = 18.dp)
        .onGloballyPositioned { coordinates ->
          val newHeightDp = with(density) { coordinates.size.height.toDp() }
          if (newHeightDp != columnHeightDp) {
            columnHeightDp = newHeightDp
          }
        }
    ) {
      SpacerTopBar()
      responseSitzungsCard?.let { SitzungsCard(it) }
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
      LazyColumn(
        modifier = Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
      ) {
        AttendanceCoordinationList(
          title = "Present",
          responses = presentList,
          isVisible = isPresentVisible,
          maxMembernumber = maxMembernumber,
          background = Text_secondary,
          onVisibilityToggle = { isPresentVisible = it }
        )

        if (responseSitzungsCard?.status == MeetingStatus.scheduled ||
          responseSitzungsCard?.status == MeetingStatus.inSession
        ) {
          AttendanceCoordinationList(
            title = "Zugesagt",
            responses = acceptedList,
            isVisible = isAcceptedVisible,
            maxMembernumber = maxMembernumber,
            background = Color(0xff1061DA),
            onVisibilityToggle = { isAcceptedVisible = it }
          )
          AttendanceCoordinationList(
            title = "Ausstehend",
            responses = pendingList,
            isVisible = isPendingVisible,
            maxMembernumber = maxMembernumber,
            onVisibilityToggle = { isPendingVisible = it }
          )
        }

        AttendanceCoordinationList(
          title = if (responseSitzungsCard?.status == MeetingStatus.scheduled ||
            responseSitzungsCard?.status == MeetingStatus.inSession
          ) "Abgesagt" else "Abwesend",
          responses = absentList,
          isVisible = isAbsentVisible,
          maxMembernumber = maxMembernumber,
          background = Color(0xffDA1043),
          onVisibilityToggle = { isAbsentVisible = it }
        )
      }
    }
  }

  Log.i("screenHeightDp", "$screenHeightDp")
  Log.e("columnHeightDp", "$columnHeightDp")
  Log.d("contentHeightDp", "$contentHeightDp")

}
  

