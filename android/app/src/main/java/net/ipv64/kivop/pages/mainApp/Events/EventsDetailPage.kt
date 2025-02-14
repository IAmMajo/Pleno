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

package net.ipv64.kivop.pages.mainApp.Events

import android.util.Log
import androidx.activity.compose.BackHandler
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
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.AttendanceCoordinationList
import net.ipv64.kivop.components.CustomButton
import net.ipv64.kivop.components.ExpandableBox
import net.ipv64.kivop.components.Label
import net.ipv64.kivop.components.Markdown
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.models.attendancesList
import net.ipv64.kivop.models.primaryButtonStyle
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime_light
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun EventCard() {
  val dateFormatter = java.time.format.DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm")

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(16.dp)) {
        Column {
          Text(
              text = "KIVoP-Event",
              color = Text_prime,
              style = MaterialTheme.typography.headlineMedium,
              fontWeight = FontWeight.Bold)
          Spacer(modifier = Modifier.height(12.dp))
          Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.fillMaxWidth()) {
            Icon(
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = "Datum",
                tint = Text_prime)
            Spacer(modifier = Modifier.width(6.dp))
            Text(
                text = "12.01.2025 | 14:30 Uhr",
                color = Text_prime,
                style = MaterialTheme.typography.bodyLarge)
            Spacer(modifier = Modifier.width(16.dp))
            Icon(
                painter = painterResource(id = R.drawable.ic_clock),
                contentDescription = "Dauer",
                tint = Text_prime)
            Spacer(modifier = Modifier.width(6.dp))
            Text(text = "90 Min", color = Text_prime, style = MaterialTheme.typography.bodyLarge)
          }
          Spacer(modifier = Modifier.height(4.dp))
          Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            // Icon für Standort
            Icon(
                painter = painterResource(id = R.drawable.ic_place),
                tint = Text_prime,
                contentDescription = "Icon Standort",
                modifier = Modifier.padding(end = 8.dp) // Abstand zwischen Icon und Text
                )
            // Text-Darstellung

            // Name der Location
            Text(
                text = "Friedrich-Heinrich-Allee 40",
                color = Text_prime,
                style = MaterialTheme.typography.bodyMedium,
                fontWeight = FontWeight.SemiBold)
          }

          //          Spacer(modifier = Modifier.height(16.dp))
          //          ProfileCardSmall(
          //            name = "Max Muster",
          //            role = "",
          //            profilePicture = null,
          //            backgroundColor = Background_secondary.copy(0.15f),
          //            texColor = Text_prime_light,
          //            onClick = {})
          //        }
          Spacer(modifier = Modifier.height(8.dp))
        }
      }
}

@Composable
fun EventAttendenceCard(
    //  user: GetAttendanceDTO,
    //  meetingStatus: MeetingStatus? = null,
    //  acceptedORpresentListcound: Int?,
    //  imgBase64: String? = null,
    //  maxMembernumber: Int,
    //  meetingViewModel: MeetingViewModel,
    //  checkInClick: () -> Unit = {},
    //  acceptClick: () -> Unit = {},
    //  declineClick: () -> Unit = {},
    //  showPopupcl: Boolean = false
) {

  val acceptedList: List<attendancesList> =
      listOf(
          attendancesList("Tom Zimmer", AttendanceStatus.accepted),
          attendancesList("Rommy Bernards", AttendanceStatus.accepted),
          attendancesList("Eva Einfach", AttendanceStatus.accepted),
      )
  val absentList: List<attendancesList> =
      listOf(
          attendancesList("Julia Jonas", AttendanceStatus.absent),
          attendancesList("Peter Fröhlich", AttendanceStatus.absent),
          attendancesList("Rainer Zufall", AttendanceStatus.absent),
      )

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
                    text = "M",
                    color = Background_prime,
                    fontSize = 18.sp,
                    style = MaterialTheme.typography.bodyLarge,
                    fontWeight = FontWeight.Bold)
              }
          Spacer(modifier = Modifier.width(5.dp))

          Text(
              text = "Max Muster",
              color = Text_prime,
              modifier = Modifier.weight(1f),
              style = MaterialTheme.typography.bodyLarge,
              lineHeight = 20.sp,
              letterSpacing = 0.1.sp,
              fontWeight = FontWeight.SemiBold)
          Spacer(modifier = Modifier.weight(1f))
          Label(backgroundColor = Tertiary) { Text("Zugesagt", color = Text_prime_light) }
        }
        // ------------------------------------------------------------------------------

        SpacerBetweenElements()

        Button(
            modifier = Modifier.fillMaxWidth(),
            colors =
                ButtonDefaults.buttonColors(
                    containerColor = Tertiary, contentColor = Text_prime_light),
            onClick = {}) {
              Text(text = "Sitzung absagen")
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
                        text = "3 / 5",
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
                        title = "Zugesagt",
                        responses = acceptedList,
                        isVisible = true,
                        maxMembernumber = 5,
                        background = Text_secondary,
                        onVisibilityToggle = { true })

                    AttendanceCoordinationList(
                        title = "Abgesagt",
                        responses = absentList,
                        isVisible = true,
                        maxMembernumber = 5,
                        background = Secondary,
                        onVisibilityToggle = { it })
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
                  } // bis hier
            })
      }
}

@Composable
fun EventsDetailPage(navController: NavController) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }

  // Placeholder
  Column(
      modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp),
  ) {
    SpacerTopBar()
    EventCard()
    SpacerBetweenElements()
    EventAttendenceCard()
    SpacerBetweenElements()
    Box(
        modifier =
            Modifier.fillMaxWidth()
                .customShadow()
                .background(Background_secondary, shape = RoundedCornerShape(8.dp))) {
          Markdown(
              modifier = Modifier,
              markdown =
                  "## Lorem ipsum \nDolor sit amet, **consetetur sadipscing** elitr, sed diam nonumy eirmod tempor invidunt ut. \n" +
                      "### Labore et dolore \n" +
                      "magna aliquyam erat, **sed diam voluptua**. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita *kasd gubergren, no sea takimata sanctus est*. Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam.",
              fontColor = Text_prime)
        }
    Spacer(modifier = Modifier.weight(1f))
    CustomButton(
        modifier = Modifier,
        buttonStyle = primaryButtonStyle,
        text = "Fahrten zum Event",
        color = Tertiary,
        fontColor = Background_prime,
        onClick = { navController.navigate("carpoolingList") })
    SpacerBetweenElements()
  }
}
