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

package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetAttendanceDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.models.viewModel.MeetingViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun LoggedUserAttendacneCard(
    user: GetAttendanceDTO,
    meetingStatus: MeetingStatus? = null,
    acceptedORpresentListcound: Int?,
    imgBase64: String? = null,
    maxMembernumber: Int,
    meetingViewModel: MeetingViewModel,
    checkInClick: () -> Unit = {},
    acceptClick: () -> Unit = {},
    declineClick: () -> Unit = {},
    showPopupcl: Boolean = false
) {
  var showPopup by remember { mutableStateOf(showPopupcl) }
  // Header
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(12.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
          Box(
              contentAlignment = Alignment.Center,
              modifier = Modifier.size(40.dp).clip(CircleShape).background(Color(0xFF1061DA))) {
                Text(
                    text = user.identity.name.first().toString(),
                    color = Background_prime,
                    fontSize = 18.sp,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold)
              }
          Spacer(modifier = Modifier.width(5.dp))

          Text(
              text = user.identity.name,
              color = Text_prime,
              modifier = Modifier.weight(1f),
              style = MaterialTheme.typography.bodyLarge,
              lineHeight = 20.sp,
              letterSpacing = 0.1.sp,
              fontWeight = FontWeight.SemiBold)
          Spacer(modifier = Modifier.weight(1f))
          if (user.status == AttendanceStatus.present) {
            Label(backgroundColor = Tertiary) { Text("Anwesend", color = Text_prime_light) }
          } else if (user.status == AttendanceStatus.absent) {
            if (meetingStatus == MeetingStatus.completed) {
              Label(backgroundColor = Signal_red) { Text("Abwesend", color = Text_prime_light) }
            } else {
              Label(backgroundColor = Signal_red) { Text("Abgesagt", color = Text_prime_light) }
            }
          } else if (user.status == AttendanceStatus.accepted) {
            Label(backgroundColor = Tertiary) { Text("Zugesagt", color = Text_prime_light) }
          } else {
            Label() { Text(text = "Ausstehend", color = Text_prime_light) }
          }
        }
        // ------------------------------------------------------------------------------

        SpacerBetweenElements()
        if (meetingStatus == MeetingStatus.scheduled) {
          if (user.status == AttendanceStatus.present) {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Tertiary, contentColor = Text_prime_light),
                onClick = { declineClick() }) {
                  Text(text = "Sitzung absagen")
                }
          } else if (user.status == AttendanceStatus.absent) {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Tertiary, contentColor = Text_prime_light),
                onClick = { acceptClick() }) {
                  Text(text = "Sitzung zusagen")
                }
          } else if (user.status == AttendanceStatus.accepted) {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Secondary, contentColor = Text_prime),
                onClick = { declineClick() }) {
                  Text(text = "Sitzung absagen")
                }
          } else {
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Tertiary, contentColor = Text_prime_light),
                onClick = { acceptClick() }) {
                  Text(text = "Sitzung zusagen")
                }
            SpacerBetweenElements(4.dp)
            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Secondary, contentColor = Text_prime),
                onClick = { declineClick() }) {
                  Text(text = "Sitzung Absagen")
                }
          }
        } else if (meetingStatus == MeetingStatus.inSession) {
          if (user.status != AttendanceStatus.present) {

            Button(
                modifier = Modifier.fillMaxWidth(),
                colors =
                    ButtonDefaults.buttonColors(
                        containerColor = Tertiary, contentColor = Text_prime_light),
                onClick = { checkInClick() }) {
                  Text(text = "Check In")
                }
          }
        }

        SpacerBetweenElements()
        ExpandableBox(
            contentFoldedIn = {
              Row(
                  verticalAlignment = Alignment.CenterVertically,
                  modifier = Modifier.fillMaxWidth().height(25.dp)) {
                    Icon(
                        painter = painterResource(id = R.drawable.ic_groups),
                        contentDescription = null,
                        tint = Text_prime,
                        modifier = Modifier.size(30.dp))
                    Spacer(modifier = Modifier.weight(1f)) // Abstand zwischen Icon und Text
                    Text(
                        text = "$acceptedORpresentListcound / $maxMembernumber",
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.SemiBold,
                        color = Text_prime)
                    Icon(
                        painter = painterResource(id = R.drawable.ic_chevron_down_24),
                        contentDescription = null,
                        tint = Text_prime,
                        modifier = Modifier.size(30.dp))
                  }
            },
            contentFoldedOut = {
              Column(
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
                          background = Signal_blue,
                          onVisibilityToggle = { meetingViewModel.isAcceptedVisible = it })
                      AttendanceCoordinationList(
                          title = "Ausstehend",
                          responses = meetingViewModel.pendingList,
                          isVisible = meetingViewModel.isPendingVisible,
                          maxMembernumber = meetingViewModel.maxMembernumber,
                          onVisibilityToggle = { meetingViewModel.isPendingVisible = it })
                    }

                    AttendanceCoordinationList(
                        title =
                            if (meetingViewModel.meeting?.status == MeetingStatus.scheduled ||
                                meetingViewModel.meeting?.status == MeetingStatus.inSession)
                                "Abgesagt"
                            else "Abwesend",
                        responses = meetingViewModel.absentList,
                        isVisible = meetingViewModel.isAbsentVisible,
                        maxMembernumber = meetingViewModel.maxMembernumber,
                        background = Signal_red,
                        onVisibilityToggle = { meetingViewModel.isAbsentVisible = it })
                    Row(
                        modifier = Modifier.fillMaxWidth().height(25.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.End) {
                          Icon(
                              painter = painterResource(id = R.drawable.ic_chevron_up_24),
                              contentDescription = null,
                              tint = Text_prime,
                              modifier = Modifier.size(30.dp))
                        }
                  }
            })
      }
}
