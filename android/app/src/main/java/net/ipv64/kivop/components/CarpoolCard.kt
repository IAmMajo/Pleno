package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
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
import net.ipv64.kivop.R
import net.ipv64.kivop.models.GetSpecialRideDTO
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter.ofPattern
import java.util.UUID

@Composable
fun CarpoolCard(
  carpool: GetSpecialRideDTO,
  onClick: () -> Unit = {}
){
  Column(
    modifier = Modifier
      .fillMaxWidth()
      .customShadow()
      .clip(shape = RoundedCornerShape(8.dp))
      .clickable { onClick() }
      .background(Background_secondary, shape = RoundedCornerShape(8.dp))
      .padding(12.dp)
  ) { 
    Box(
      modifier = Modifier.fillMaxWidth()
    ) { 
      Column {
        Text(text = carpool.name, style = MaterialTheme.typography.titleMedium)
        Text(text = carpool.starts.format(ofPattern("dd.MM.yyyy")), style = MaterialTheme.typography.bodyMedium)
      }
      Box(
        modifier = Modifier
          .background(Primary.copy(0.2f), shape = RoundedCornerShape(4.dp))
          .padding(horizontal = 4.dp)
          .align(alignment = Alignment.BottomEnd)
      ) { 
        Row(
          verticalAlignment = Alignment.CenterVertically
        ) {
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

@Preview
@Composable
fun previewCarpoolCard(){
  Column {
    CarpoolCard(
      carpool = GetSpecialRideDTO(
        id = UUID.randomUUID(),
        name = "Geschäftsessen",
        starts = LocalDateTime.now(),
        ends = LocalDateTime.now(),
        emptySeats = 4,
        allocatedSeats = 1,
        isSelfDriver = true,
        isSelfAccepted = true
      )
    )
    SpacerBetweenElements()
    CarpoolCard(
      carpool = GetSpecialRideDTO(
        id = UUID.randomUUID(),
        name = "Geschäftsessen",
        starts = LocalDateTime.now(),
        ends = LocalDateTime.now(),
        emptySeats = 4,
        allocatedSeats = 1,
        isSelfDriver = true,
        isSelfAccepted = true
      )
    )
    SpacerBetweenElements()
    CarpoolCard(
      carpool = GetSpecialRideDTO(
        id = UUID.randomUUID(),
        name = "Geschäftsessen",
        starts = LocalDateTime.now(),
        ends = LocalDateTime.now(),
        emptySeats = 4,
        allocatedSeats = 1,
        isSelfDriver = true,
        isSelfAccepted = true
      )
    )
  }
}