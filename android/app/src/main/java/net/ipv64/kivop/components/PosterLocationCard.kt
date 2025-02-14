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
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.UUID
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.dtos.PosterServiceDTOs.ResponsibleUsersDTO
import net.ipv64.kivop.models.viewModel.UserViewModel
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime70
import net.ipv64.kivop.ui.theme.Text_prime_light

@OptIn(ExperimentalEncodingApi::class)
@Composable
fun PosterLocationCard(
    poster: PosterPositionResponseDTO,
    image: String? = null,
    userViewModel: UserViewModel,
    address: String? = null,
    onClick: () -> Unit
) {
  val base64ImageByteArray = remember { mutableStateOf<ByteArray?>(null) }
  LaunchedEffect(image) {
    withContext(Dispatchers.IO) {
      if (image != null) {
        val decodedImage = image.substringAfter("base64").let { Base64.decode(it) }
        base64ImageByteArray.value = decodedImage
      }
    }
  }

  Box(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .clip(RoundedCornerShape(8.dp))
              .clickable { onClick() }
              .background(Background_secondary)
              .padding(8.dp)) {
        Column {
          Row(
              modifier = Modifier.fillMaxWidth(),
              verticalAlignment = Alignment.CenterVertically,
          ) {
            Box(
                Modifier.size(60.dp).clip(RoundedCornerShape(8.dp)).background(Primary_20),
                contentAlignment = Alignment.Center) {
                  if (image == null && poster.status == PosterPositionStatus.toHang) {
                    IconBox(
                        icon = ImageVector.vectorResource(R.drawable.ic_image),
                        height = 60.dp,
                        backgroundColor = Primary_20,
                        tint = Primary)
                  } else if (image == null) {
                    CircularProgressIndicator()
                  } else {
                    AsyncImage(
                        model = base64ImageByteArray.value,
                        contentDescription = null,
                        contentScale = ContentScale.Crop,
                        modifier =
                            Modifier.clip(shape = RoundedCornerShape(8.dp))
                                .width(60.dp)
                                .aspectRatio(1f)
                                .background(Color.LightGray),
                    )
                  }
                }
            SpacerBetweenElements(8.dp)
            Column(modifier = Modifier.weight(1f)) {
              if (address != null) {
                Text(
                    text = address.replaceAfter(',', "").trim(','),
                    color = Text_prime,
                    style = TextStyles.subHeadingStyle)
                Text(
                    text = address.replaceBefore(',', "").trim(','),
                    color = Text_prime70,
                    style = TextStyles.largeContentStyle)
              } else {
                if (address != null) {
                  Text(
                      text = "Straße Hausnummer",
                      softWrap = true,
                      color = Text_prime,
                      style = TextStyles.subHeadingStyle)
                  Text(
                      text = "Postleitzahl Stadt",
                      color = Text_prime70,
                      style = TextStyles.largeContentStyle)
                }
              }
            }
          }
          SpacerBetweenElements(8.dp)
          Row {
            Box(
                modifier =
                    Modifier.background(Signal_red.copy(0.2f), shape = RoundedCornerShape(2.dp))
                        .padding(horizontal = 4.dp, vertical = 2.dp)) {
                  val formatter = DateTimeFormatter.ofPattern("dd.MM.yyyy")
                  val takeDownDate = poster.expiresAt.format(formatter)
                  Text(
                      text = "Abzuhängen: $takeDownDate",
                      style = TextStyles.contentStyle,
                      color = Signal_red)
                }
            Spacer(Modifier.weight(1f))
            var lable = ""
            var lableColor = Signal_neutral
            when {
              poster.status == PosterPositionStatus.toHang -> {
                lable = "Offen"
                lableColor = Secondary
              }
              poster.status == PosterPositionStatus.hangs -> {
                lable = "Aufgehangen"
                lableColor = Secondary
              }
              poster.status == PosterPositionStatus.overdue -> {
                lable = "Überfällig"
                lableColor = Signal_red
              }
              poster.status == PosterPositionStatus.takenDown -> {
                lable = "Abgehangen"
                lableColor = Secondary
              }
              poster.status == PosterPositionStatus.damaged -> {
                lable = "Beschädigt"
                lableColor = Signal_red
              }
            }
            // Check if user is responsible for poster
            if (poster.responsibleUsers.any { it.id == userViewModel.getID() }) {
              Box(
                  modifier =
                      Modifier.background(Primary, shape = CircleShape)
                          .wrapContentSize()
                          .padding(horizontal = 6.dp, vertical = 2.dp)) {
                    Text(
                        text = "+",
                        softWrap = false,
                        style = TextStyles.contentStyle,
                        color = Text_prime_light)
                  }
            }
            SpacerBetweenElements(4.dp)
            Box(
                modifier =
                    Modifier.background(lableColor, shape = RoundedCornerShape(50.dp))
                        .wrapContentWidth()
                        .padding(horizontal = 8.dp, vertical = 2.dp)) {
                  Text(
                      text = lable,
                      softWrap = false,
                      style = TextStyles.contentStyle,
                      color = Text_prime_light)
                }
          }
        }
      }
}

@Preview
@Composable
fun PosterLocationCardPreview() {
  PosterLocationCard(
      poster =
          PosterPositionResponseDTO(
              id = UUID.randomUUID(),
              posterId = null,
              latitude = 0.0,
              longitude = 0.0,
              postedBy = null,
              postedAt = null,
              expiresAt = LocalDateTime.now(),
              removedBy = null,
              removedAt = null,
              responsibleUsers =
                  List(size = 3, init = { ResponsibleUsersDTO(UUID.randomUUID(), "Test") }),
              status = PosterPositionStatus.hangs,
          ),
      address = "Teststra4234242234234ße 1, test",
      onClick = {},
      userViewModel = UserViewModel())
}
