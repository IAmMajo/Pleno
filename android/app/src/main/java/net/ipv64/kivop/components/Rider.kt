package net.ipv64.kivop.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import java.util.UUID
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.RideServiceDTOs.GetRiderDTO
import net.ipv64.kivop.services.base64ToBitmap
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun RiderCard(
    rider: GetRiderDTO,
    address: String? = null,
    profilePicture: String? = null,
    onAccept: () -> Unit,
    onDecline: () -> Unit,
    enableDecline: Boolean = true
) {
  Row(
      modifier =
          Modifier.fillMaxWidth()
              .height(68.dp)
              .clip(shape = RoundedCornerShape(8.dp))
              .padding(8.dp),
      verticalAlignment = Alignment.CenterVertically) {
        if (profilePicture != null) {
          base64ToBitmap(profilePicture)?.asImageBitmap()?.let {
            Image(
                it,
                contentDescription = "Profile Picture",
                contentScale = ContentScale.Crop,
                modifier = Modifier.fillMaxHeight().aspectRatio(1f).clip(shape = CircleShape))
          }
        } else {
          // Todo: replace with ProfileImgPlaceholder compomnente
          Box(
              modifier =
                  Modifier.fillMaxHeight()
                      .aspectRatio(1f)
                      .clip(shape = CircleShape)
                      .background(Signal_blue)) {
                Text(
                    text = rider.username[0].toString().uppercase(),
                    modifier = Modifier.align(Alignment.Center),
                    style = MaterialTheme.typography.headlineLarge,
                    color = Background_secondary)
              }
        }
        Spacer(modifier = Modifier.size(16.dp))
        Column() {
          Text(text = rider.username, style = TextStyles.largeContentStyle, color = Text_prime)
          Text(text = address ?: "", style = TextStyles.contentStyle, color = Text_tertiary)
        }
        Spacer(modifier = Modifier.weight(1f))
        when (rider.accepted) {
          false -> {
            IconBoxClickable(
                icon = ImageVector.vectorResource(R.drawable.ic_add),
                backgroundColor = Color.Transparent,
                tint = Signal_neutral,
                onClick = onAccept)
          }
          true -> {
            if (enableDecline) {
              IconBoxClickable(
                  icon = ImageVector.vectorResource(R.drawable.ic_remove),
                  backgroundColor = Color.Transparent,
                  tint = Signal_neutral,
                  onClick = onDecline)
            }
          }
        }
      }
}

@Preview
@Composable
fun RiderPreview() {
  RiderCard(
      GetRiderDTO(
          id = UUID.randomUUID(),
          userID = UUID.randomUUID(),
          username = "hans",
          latitude = 3.000F,
          longitude = 3.000F,
          itsMe = false,
          accepted = false),
      address = "Am Viegenhof 8, 47445 moers",
      onAccept = {},
      onDecline = {})
}
