package net.ipv64.kivop.components

import android.content.Context
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.compose.rememberAsyncImagePainter
import coil3.request.ImageRequest
import coil3.request.crossfade
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.models.PosterNeedDTO
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.services.base64ToBitmap
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_red
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.UUID

@Composable
fun PosterInfoCard(
  poster: PosterNeedDTO,
  showMaps: Boolean = true,
  clickable: Boolean = true,
  onPosterClick: () -> Unit = {}
){
  val clickableModifier = if (clickable) Modifier.clickable { onPosterClick() } else Modifier
  Column(
    modifier = Modifier
      .fillMaxWidth()
      .customShadow()
      .clip(shape = RoundedCornerShape(8.dp))
      .background(Background_secondary)
      .then(clickableModifier)
      .padding(12.dp),
  ) {
    Row() {
      AsyncImage(
        model = poster.imageBase64,
        contentDescription = null,
        modifier = Modifier
          .width(100.dp)
          .aspectRatio(24f / 36f)
          .background(Color.Black, shape = RoundedCornerShape(8.dp)),
      )
      Spacer(modifier = Modifier.width(12.dp))
      Column(

      ) {
        Text(text = poster.name, style = MaterialTheme.typography.headlineSmall)
        poster.description?.let {
          Text(
            text = it,
            style = MaterialTheme.typography.bodySmall
          )
        }
        Box(
          modifier = Modifier.background(
            Signal_red.copy(0.3f),
            shape = RoundedCornerShape(2.dp)
          ).padding(horizontal = 4.dp)
        ) {
          val formatter = DateTimeFormatter.ofPattern("d/MM/yyyy")
          val takeDownDate = poster.removeDate.format(formatter)
          Text(
            text = "Abzuhängen: $takeDownDate",
            style = MaterialTheme.typography.bodySmall,
            color = Signal_red
          )
        }
      }
    }
    SpacerBetweenElements()
    MultiProgressBar(
      progress1 = poster.needHangedPosters,
      progress2 = poster.hangedPosters,
      progress3 = poster.tokenDownPosters,
      progress1Color = Secondary,
      progress2Color = Primary,
      progress3Color = Signal_neutral,
      progress1Label = "Offen",
      progress2Label = "Aufgehangen",
      progress3Label = "Abgehangen",
      barHeight = 16
    )
    if (showMaps){
      SpacerBetweenElements()
      //TODO: google maps
      Box(modifier = Modifier.fillMaxWidth().height(150.dp).clip(shape = RoundedCornerShape(8.dp)).background(Signal_neutral)) {
        Text(text = "Google Maps", modifier = Modifier.align(Alignment.Center))
      }
    }
  }
}

@Preview(showBackground = true)
@Composable
fun PreviewPosterInfoCard(){
  PosterInfoCard(
    poster = PosterNeedDTO(
      id = "1234".let { UUID.fromString(it) },
      name = "Test",
      description = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam volu",
      imageBase64 = getString(R.raw.raw),
      removeDate = LocalDateTime.now(),
      
      needHangedPosters = 2,
      hangedPosters = 31,
      tokenDownPosters = 9,
      lat = 52.520008,
      lon = 34.230023,
    )
  )
}
