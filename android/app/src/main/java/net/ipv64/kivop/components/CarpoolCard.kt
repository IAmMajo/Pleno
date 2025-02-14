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
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter.ofPattern
import java.util.UUID
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.RideServiceDTOs.GetSpecialRideDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.UsersRideState
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary

@Composable
fun CarpoolCard(carpool: GetSpecialRideDTO, onClick: () -> Unit = {}) {
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .clip(shape = RoundedCornerShape(8.dp))
              .clickable { onClick() }
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(12.dp)) {
        Box(modifier = Modifier.fillMaxWidth()) {
          Column {
            Text(text = carpool.name, style = MaterialTheme.typography.titleMedium)
            Text(
                text = carpool.starts.format(ofPattern("dd.MM.yyyy")),
                style = MaterialTheme.typography.bodyMedium)
          }
          Row(
              modifier = Modifier.align(alignment = Alignment.BottomEnd),
          ) {
            if (carpool.openRequests != null && carpool.myState == UsersRideState.driver) {
              Box(
                  modifier =
                      Modifier.height(20.dp)
                          .background(Primary.copy(0.2f), shape = RoundedCornerShape(4.dp))
                          .padding(horizontal = 4.dp)) {
                    Row(
                        modifier = Modifier.fillMaxHeight(),
                        verticalAlignment = Alignment.CenterVertically) {
                          Text(
                              text = carpool.openRequests.toString(),
                              color = Primary,
                              style = MaterialTheme.typography.labelMedium)
                        }
                  }
              SpacerBetweenElements(4.dp)
            }
            Box(
                modifier =
                    Modifier.height(20.dp)
                        .background(Primary.copy(0.2f), shape = RoundedCornerShape(4.dp))
                        .padding(horizontal = 4.dp)) {
                  Row(
                      modifier = Modifier.fillMaxHeight(),
                      verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = carpool.myState.toString(),
                            color = Primary,
                            style = MaterialTheme.typography.labelMedium)
                      }
                }
            SpacerBetweenElements(4.dp)
            Box(
                modifier =
                    Modifier.height(20.dp)
                        .background(Primary.copy(0.2f), shape = RoundedCornerShape(4.dp))
                        .padding(horizontal = 4.dp)) {
                  Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = "${carpool.allocatedSeats}/${carpool.emptySeats} Plätze",
                        color = Primary,
                        style = MaterialTheme.typography.labelMedium)
                    Icon(
                        painter = painterResource(R.drawable.ic_person_24),
                        contentDescription = "seats",
                        tint = Primary)
                  }
                }
          }
        }
      }
}

@Preview
@Composable
fun previewCarpoolCard() {
  Column {
    CarpoolCard(
        carpool =
            GetSpecialRideDTO(
                id = UUID.randomUUID(),
                name = "Geschäftsessen",
                starts = LocalDateTime.now(),
                ends = LocalDateTime.now(),
                emptySeats = 3u,
                allocatedSeats = 2u,
                myState = UsersRideState.driver,
                openRequests = 3,
            ))
  }
}
