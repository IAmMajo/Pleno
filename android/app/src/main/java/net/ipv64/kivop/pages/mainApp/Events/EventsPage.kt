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

import android.inputmethodservice.Keyboard.Row
import android.util.Log
import androidx.activity.compose.BackHandler
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.Icon
import androidx.compose.material.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import java.time.format.DateTimeFormatter
import net.ipv64.kivop.BackPressed.isBackPressed
import net.ipv64.kivop.R
import net.ipv64.kivop.components.Label
import net.ipv64.kivop.components.SpacerBetweenElements
import net.ipv64.kivop.components.SpacerTopBar
import net.ipv64.kivop.dtos.RideServiceDTOs.GetEventDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.UsersEventState
import net.ipv64.kivop.dtos.RideServiceDTOs.eventA
import net.ipv64.kivop.dtos.RideServiceDTOs.eventB
import net.ipv64.kivop.dtos.RideServiceDTOs.eventC
import net.ipv64.kivop.dtos.RideServiceDTOs.eventD
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_secondary

@Composable
fun EventsPage(navController: NavController) {
  BackHandler {
    isBackPressed = navController.popBackStack()
    Log.i("BackHandler", "BackHandler: $isBackPressed")
  }
  // Your composable code here

  // Placeholder
  Column(
      modifier = Modifier.fillMaxSize().padding(horizontal = 22.dp),
  ) {
    SpacerTopBar()
    EventListItem(eventA, { navController.navigate("events/mockEvent") })
    SpacerBetweenElements(8.dp)
    EventListItem(eventD, { navController.navigate("events/mockEvent") })
    SpacerBetweenElements(8.dp)
    EventListItem(eventB, { navController.navigate("events/mockEvent") })
    SpacerBetweenElements(8.dp)
    EventListItem(eventC, { navController.navigate("events/mockEvent") })
  }
}

@Composable
fun EventListItem(
    itemListData: GetEventDTO,
    onClick: (() -> Unit)? = {},
) {
  val dateFormatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
  val timeFormatter = DateTimeFormatter.ofPattern("HH:mm")
  val iconData = painterResource(id = R.drawable.event_today_20dp)
  val iconColor = Signal_blue

  // ToDo - haben Umfragen ein Label? in DTOs schauen

  val textLabel =
      when (itemListData.myState) {
        UsersEventState.nothing -> "Ausstehend"
        UsersEventState.present -> "Zugesagt"
        UsersEventState.absent -> "Abgesagt"
      }

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow(cornersRadius = 8.dp, shadowBlurRadius = 2.dp)
              .clip(RoundedCornerShape(8.dp))
              .clickable(onClick = onClick!!)
              .background(Background_secondary)
              .padding(8.dp),
  ) {
    Column(modifier = Modifier) {
      // Heading-Row
      Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
        // Icon
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
        SpacerBetweenElements(8.dp)

        // Titel
        Text(
            text = itemListData.name,
            fontWeight = FontWeight.SemiBold,
            fontSize = 18.sp,
            color = Text_prime,
            modifier = Modifier.weight(1f))

        // ToDO
        Label(backgroundColor = iconColor) {
          Text(
              text = textLabel,
              fontWeight = FontWeight.SemiBold,
              fontSize = 12.sp,
              color = Background_secondary,
          )
        }
      }
      SpacerBetweenElements(8.dp)

      // ItemDetails-Row
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
                    "${itemListData.starts.format(dateFormatter)} | ${
          itemListData.starts.format(
            timeFormatter
          )
        }",
                color = Text_secondary,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold)

            // Spacer füllt den Platz bis zur zweiten Gruppe
            Spacer(modifier = Modifier.weight(1f))
            // Zweite Gruppe
            Icon(
                painter = painterResource(id = R.drawable.ic_calendar),
                contentDescription = null,
                tint = Signal_red,
                modifier = Modifier.size(18.dp))
            Spacer(modifier = Modifier.width(4.dp)) // Abstand zwischen Icon und Text
            Text(
                text =
                    "${itemListData.ends.format(dateFormatter)} | ${
          itemListData.ends.format(
            timeFormatter
          )
        }",
                color = Signal_red,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold)
          }
    }
  }
}
