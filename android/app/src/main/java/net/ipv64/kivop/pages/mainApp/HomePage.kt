// MIT No Attribution
// 
// Copyright 2025 KIVoP
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.pages.mainApp

import android.app.Activity
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.zIndex
import androidx.navigation.NavController
import net.ipv64.kivop.components.BulletList
import net.ipv64.kivop.components.InToSitzungCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.models.viewModel.MeetingsViewModel
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.ui.customRoundedTopWithShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Text_prime_light

data class TopAppBarConfig(val title: String, val actions: @Composable RowScope.() -> Unit = {})

@Composable
fun HomePage(
    navController: NavController,
    userViewModel: UserViewModel,
    meetingsViewModel: MeetingsViewModel
) {
  val context = LocalContext.current
  BackHandler { (context as? Activity)?.moveTaskToBack(true) }
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
            InToSitzungCard(
                currentMeeting,
                onClick = { navController.navigate("anwesenheit/${currentMeeting.id}") })
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
}
