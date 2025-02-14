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

package net.ipv64.kivop.pages.mainApp.Protocol

import AgendaCard
import CustomEFAB
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavController
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.IconBoxClickable
import net.ipv64.kivop.components.LoggedUserAttendacneCard
import net.ipv64.kivop.components.MarkdownPreviewTab
import net.ipv64.kivop.components.PopupGenerateSocialMediaPost
import net.ipv64.kivop.components.SitzungsCard
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.RecordStatus
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.models.viewModel.MeetingViewModel
import net.ipv64.kivop.models.viewModel.MeetingViewModelFactory
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.services.GetScreenHeight
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ProtocolDetailPage(
    navController: NavController,
    meetingId: String,
    meetingViewModel: MeetingViewModel = viewModel(factory = MeetingViewModelFactory(meetingId)),
    userViewModel: UserViewModel
) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  val screenHeightDp = GetScreenHeight()
  var columnHeightDp by remember { mutableStateOf(0.dp) }
  val density = LocalDensity.current
  var user = userViewModel.getProfile()
  val contentHeightDp by
      remember(screenHeightDp, columnHeightDp) {
        derivedStateOf { screenHeightDp - columnHeightDp }
      }

  var isDelayedVisible by remember { mutableStateOf(false) }
  var isAgendaCardVisible by remember { mutableStateOf(false) }
  var selectedLanguage by remember { mutableStateOf("de") }
  var kiGenerierterText by remember { mutableStateOf("") }

  LaunchedEffect(meetingViewModel.attendance.isNotEmpty()) {
    isDelayedVisible = meetingViewModel.attendance.isNotEmpty()
    delay(300)
    isAgendaCardVisible = true
  }

  // 🔹 **Ersetze die Column durch eine Box**, um FAB richtig zu positionieren
  Box(modifier = Modifier.fillMaxSize()) {
    Column(modifier = Modifier.fillMaxSize().background(Tertiary)) {
      // Oberer Bereich
      Column(
          modifier =
              Modifier.fillMaxWidth().onGloballyPositioned { coordinates ->
                val newHeightDp = with(density) { coordinates.size.height.toDp() }
                if (newHeightDp != columnHeightDp) {
                  columnHeightDp = newHeightDp
                }
              }) {
            SpacerTopBar()
            meetingViewModel.meeting?.let {
              SitzungsCard(it, protocoll = meetingViewModel.protocols)
            }
          }

      val scope = rememberCoroutineScope()

      // Hauptinhalt
      val offsetY by
          animateDpAsState(
              targetValue = if (isDelayedVisible) 0.dp else contentHeightDp,
              animationSpec = tween(durationMillis = 500))

      Column(
          modifier =
              Modifier.offset(y = offsetY)
                  .fillMaxHeight()
                  .clip(RoundedCornerShape(topStart = 14.dp, topEnd = 14.dp))
                  .background(Background_prime)
                  .padding(top = 18.dp, start = 18.dp, end = 18.dp),
      ) {
        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxWidth(),
            horizontalAlignment = Alignment.Start) {
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
                      meetingViewModel = meetingViewModel)
                }
                SpacerBetweenElements()
              }

              item {
                if (isAgendaCardVisible && meetingViewModel.protocols.isNotEmpty()) {

                  Column(modifier = Modifier.fillMaxWidth()) {
                    Row(
                        modifier = Modifier.fillMaxWidth().height(30.dp),
                        verticalAlignment = Alignment.CenterVertically) {
                          Text(
                              text = "Protokoll",
                              style = MaterialTheme.typography.headlineMedium,
                              color = Text_prime,
                          )

                          Spacer(modifier = Modifier.weight(1f))

                          var expanded by remember { mutableStateOf(false) }

                          Row(
                              modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                              verticalAlignment = Alignment.CenterVertically) {
                                Text(
                                    text = selectedLanguage,
                                    style = MaterialTheme.typography.headlineMedium,
                                    color = Text_prime)

                                Box {
                                  IconButton(onClick = { expanded = !expanded }) {
                                    Icon(
                                        Icons.Default.MoreVert, contentDescription = "More options")
                                  }
                                  DropdownMenu(
                                      expanded = expanded,
                                      onDismissRequest = { expanded = false },
                                      modifier = Modifier.background(color = Secondary)) {
                                        meetingViewModel.protocols.forEach { option ->
                                          DropdownMenuItem(
                                              text = { Text(option.lang) },
                                              onClick = {
                                                selectedLanguage = option.lang
                                                expanded = false
                                              })
                                        }
                                      }
                                }
                              }
                        }
                  }

                  SpacerBetweenElements()

                  Column {
                    for (protocol in meetingViewModel.protocols) {
                      if (protocol.lang == selectedLanguage) {
                        meetingViewModel.meeting?.let {
                          if (user != null) {
                            if ((user.isAdmin && protocol.status != RecordStatus.approved) ||
                                (protocol.iAmTheRecorder &&
                                    protocol.status != RecordStatus.approved)) {
                              AgendaCard(
                                  name = it.name,
                                  content =
                                      protocol.content +
                                          "\n" +
                                          protocol.votingResultsAppendix +
                                          "\n" +
                                          protocol.attendancesAppendix,
                                  EditBox = {
                                    IconBoxClickable(
                                        icon = ImageVector.vectorResource(id = R.drawable.ic_edit),
                                        onClick = {
                                          navController.navigate(
                                              "protokolleEdit/${it.id}/${selectedLanguage}")
                                        },
                                        backgroundColor = Tertiary.copy(0.19f),
                                        tint = Tertiary)
                                  })
                            } else {
                              AgendaCard(
                                  name = it.name,
                                  content =
                                      protocol.content +
                                          "\n" +
                                          protocol.votingResultsAppendix +
                                          "\n" +
                                          protocol.attendancesAppendix,
                              )
                            }
                          }
                        }
                      }
                    }
                  }

                  SpacerBetweenElements()
                }
              }
            }
      }
    }
    var isExpanded by remember { mutableStateOf(false) } // Gemeinsamer State für FAB & Popup
    var kiGenerierterText by remember { mutableStateOf("") } // Speichert den generierten Text

    CustomEFAB(
        isExpanded = isExpanded,
        onExpandChange = { isExpanded = it }, // Steuert FAB & Popup gemeinsam
        expandedContent = {
          val linesList by meetingViewModel.lines.collectAsState()

          LaunchedEffect(selectedLanguage) {
            for (protocol in meetingViewModel.protocols) {
              if (protocol.lang == selectedLanguage) {
                meetingViewModel.startSocialMediaPost(protocol.content, selectedLanguage)
              }
            }
          }

          LaunchedEffect(linesList) {
            if (linesList.isNotEmpty()) {
              kiGenerierterText = linesList.joinToString("\n")
              meetingViewModel.clearLines()
            }
          }

          PopupGenerateSocialMediaPost(
              contentToShare = kiGenerierterText,
              title = "Social Media Post",
              onDismiss = { isExpanded = false },
              content = { MarkdownPreviewTab(markdown = kiGenerierterText, modifier = Modifier) })
        })
  }
}
