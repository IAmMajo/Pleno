package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.painter.Painter
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import java.time.format.DateTimeFormatter
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.MeetingStatus
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun ListenItem(
    itemListData: GetMeetingDTO,
    onClick: () -> Unit = {},
    isProtokoll: Boolean = false
) {
  val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
  val iconData: Painter
  val iconColor: Color

  if (!isProtokoll) {
    iconData =
        if (itemListData.status != MeetingStatus.completed) {
          when (itemListData.myAttendanceStatus) {
            null -> painterResource(id = R.drawable.ic_event_open)
            AttendanceStatus.accepted,
            AttendanceStatus.present -> painterResource(id = R.drawable.ic_event_check)
            else -> painterResource(id = R.drawable.ic_event_cancel)
          }
        } else {
          when (itemListData.myAttendanceStatus) {
            null -> painterResource(id = R.drawable.ic_event_cancel)
            AttendanceStatus.accepted -> painterResource(id = R.drawable.ic_event_cancel)
            AttendanceStatus.present -> painterResource(id = R.drawable.ic_event_check)
            else -> painterResource(id = R.drawable.ic_event_cancel)
          }
        }
  } else {
    iconData = painterResource(id = R.drawable.ic_description)
  }

  if (!isProtokoll) {
    iconColor =
        if (itemListData.status != MeetingStatus.completed) {
          when (itemListData.myAttendanceStatus) {
            null -> Signal_neutral
            AttendanceStatus.accepted,
            AttendanceStatus.present -> Signal_blue
            else -> Signal_red
          }
        } else {
          when (itemListData.myAttendanceStatus) {
            null,
            AttendanceStatus.accepted -> Signal_red
            AttendanceStatus.present -> Signal_blue
            else -> Signal_red
          }
        }
  } else {
    iconColor = Signal_blue
  }

  val textLabel =
      if (itemListData.status != MeetingStatus.completed) {
        when (itemListData.myAttendanceStatus) {
          null -> "Ausstehend"
          AttendanceStatus.present -> "Present"
          AttendanceStatus.accepted -> "Zugesagt"
          else -> "Abgesagt"
        }
      } else {
        when (itemListData.myAttendanceStatus) {
          AttendanceStatus.present -> "Present"
          else -> "Abgesagt"
        }
      }

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow(cornersRadius = 0.dp, shadowBlurRadius = 10.dp)
              .clip(RoundedCornerShape(8.dp))
              .background(Background_secondary)
              .padding(8.dp)
              .clickable(onClick = onClick),
  ) {
    Column(modifier = Modifier) {
      Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier =
                Modifier.clip(RoundedCornerShape(8.dp))
                    .background(iconColor.copy(0.19f))
                    .height(44.dp)
                    .width(44.dp)
                    .padding(5.dp),
            contentAlignment = Alignment.Center) {
              Icon(
                  painter = iconData,
                  contentDescription = null,
                  tint = iconColor,
                  modifier = Modifier.size(44.dp))
            }
        Spacer(modifier = Modifier.width(8.dp))
        Text(
            text = itemListData.name,
            fontWeight = FontWeight.SemiBold,
            fontSize = 18.sp,
            color = Text_prime,
            modifier = Modifier.weight(1f))
        if (!isProtokoll) {
          Label(backgroundColor = iconColor) {
            Text(
                text = textLabel,
                fontWeight = FontWeight.SemiBold,
                fontSize = 12.sp,
                color = Background_secondary,
            )
          }
        }
      }

      Spacer(modifier = Modifier.height(8.dp))

      Row(
          modifier = Modifier.fillMaxWidth().heightIn(20.dp), // Mindesthöhe der Row
          verticalAlignment = Alignment.CenterVertically // Vertikal zentrieren
          ) {
            // Erste Gruppe bleibt unverändert
            Icon(
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = null,
                tint = Text_secondary,
                modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(4.dp)) // Abstand zwischen Icon und Text
            Text(
                text =
                    "${itemListData.start.format(dateFormatter)} | ${
            itemListData.start.format(
              timeFormatter
            )
          }",
                color = Text_secondary,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold)

            // Spacer füllt den Platz bis zur zweiten Gruppe
            Spacer(modifier = Modifier.weight(1f))

            if (!isProtokoll) {
              // Zweite Gruppe: Horizontal und vertikal zentriert
              Row(
                  horizontalArrangement = Arrangement.Center, // Horizontal zentriert
              ) {
                Icon(
                    painter = painterResource(id = R.drawable.ic_clock),
                    contentDescription = null,
                    tint = Text_secondary,
                    modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(4.dp)) // Abstand zwischen Icon und Text
                Text(
                    text = "${itemListData.duration} Min",
                    color = Text_secondary,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold)
              }
            }

            if (!isProtokoll) {
              // Dritte Gruppe: Ganz nach rechts
              Spacer(
                  modifier = Modifier.weight(1f)) // Füllt Platz zwischen zweiter und dritter Gruppe
              Icon(
                  painter = painterResource(id = R.drawable.ic_place),
                  contentDescription = null,
                  tint = Text_secondary,
                  modifier = Modifier.size(18.dp))
              Spacer(modifier = Modifier.width(4.dp)) // Abstand zwischen Icon und Text
              Text(
                  text = "${itemListData.location?.name}",
                  color = Text_secondary,
                  fontSize = 12.sp,
                  fontWeight = FontWeight.SemiBold)
            }
          }
    }
  }
}
