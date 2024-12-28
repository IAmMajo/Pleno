package net.ipv64.kivop.pages.mainApp

import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.components.BulletList
import net.ipv64.kivop.components.IconBox
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.models.viewModel.MeetingsViewModel
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.ui.customRoundedTopWithShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime_light

data class TopAppBarConfig(val title: String, val actions: @Composable RowScope.() -> Unit = {})

@Composable
fun HomePage(
    navController: NavController,
    userViewModel: UserViewModel,
    meetingsViewModel: MeetingsViewModel
): TopAppBarConfig {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  val meetings = meetingsViewModel.loadMeetings()
  var currentMeeting: GetMeetingDTO? = null
  var nextMeetings: List<GetMeetingDTO?> = emptyList()

  if (meetings.isNotEmpty()) {
    currentMeeting = meetings.first()!!
    nextMeetings = meetings.drop(1).take(3)
  }

  Column(modifier = Modifier.background(Primary)) {
    // Spacer for top bar
    SpacerTopBar()
    Column(
        modifier =
            Modifier.zIndex(1f).fillMaxWidth().padding(top = 16.dp, start = 18.dp, end = 18.dp)) {
          Text(
              if (userViewModel.getProfile() == null) "Hallo, Gast!"
              else "Hallo, ${userViewModel.getProfile()?.name}!",
              color = Text_prime_light,
              style = MaterialTheme.typography.headlineLarge)
          SpacerBetweenElements()
          if (currentMeeting != null) {
            SitzungsCard(currentMeeting)
          }
        }
    Column(
        modifier =
            Modifier.fillMaxWidth()
                .weight(1f)
                .customRoundedTopWithShadow(
                    color = Background_prime,
                    heightOffset = 40.dp,
                    // shadow
                    shadowColor = Color.Black,
                    offsetX = 0.dp,
                    offsetY = 4.dp)
                .background(Background_prime)
                .padding(top = 18.dp)
                .padding(horizontal = 18.dp)) {
          val list = nextMeetings
          BulletList("Bevorstehende Sitzungen", list)
        }
  }
  val appBarConfig =
      TopAppBarConfig(
          title = "Home",
          actions = {
            IconBox(
                Icons.Default.Home,
                height = 50.dp,
                Background_secondary.copy(alpha = 0.15f),
                Background_secondary,
                onClick = {})
          })

  return appBarConfig
}
