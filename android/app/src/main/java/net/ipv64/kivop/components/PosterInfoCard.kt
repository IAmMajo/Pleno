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
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.compose.rememberAsyncImagePainter
import coil3.request.ImageRequest
import coil3.request.crossfade
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.models.PosterNeedDTO
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.services.base64ToBitmap
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.ProgressBarGray
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Signal_neutral
import net.ipv64.kivop.ui.theme.Signal_red
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_secondary
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.UUID
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

@OptIn(ExperimentalEncodingApi::class)
@Composable
fun PosterInfoCard(
  poster: PosterResponseDTO,
  summary: PosterSummaryResponseDTO?,
  showMaps: Boolean = true,
  clickable: Boolean = true,
  onPosterClick: () -> Unit = {},
  map: @Composable () -> Unit = {}
){
  //Format image string
  val base64ImageByteArray = remember { mutableStateOf<ByteArray?>(null) }
  LaunchedEffect(poster.image) {
    withContext(Dispatchers.IO) {
      val decodedImage = poster.image.substringAfter("base64").let { Base64.decode(it) }
      base64ImageByteArray.value = decodedImage
    }
  }
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
        model = base64ImageByteArray.value,
        contentDescription = null,
        modifier = Modifier
          .width(100.dp)
          .aspectRatio(24f / 36f)
          .background(Color.LightGray, shape = RoundedCornerShape(8.dp)),
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
        if (summary != null){
          Box(
            modifier = Modifier.background(
              Signal_red.copy(0.2f),
              shape = RoundedCornerShape(2.dp)
            ).padding(horizontal = 4.dp,vertical = 2.dp)
          ) {
            val formatter = DateTimeFormatter.ofPattern("d/MM/yyyy")
            val takeDownDate = summary.nextTakeDown?.format(formatter)
            Text(
              text = "Abzuhängen: $takeDownDate",
              style = TextStyles.contentStyle,
              color = Signal_red
            )
          }
        }
      }
    }
    SpacerBetweenElements()
    if (summary != null){
      MultiProgressBar(
        progress1 = summary.toHang,
        progress2 = summary.hangs,
        progress3 = summary.takenDown,
        progress4 = summary.overdue,
        progress1TextColor = Text_secondary,
        progress2TextColor = Tertiary,
        progress3TextColor = Text_prime,
        progress4TextColor = Signal_red,
        progress1Color = Secondary,
        progress2Color = Tertiary,
        progress3Color = ProgressBarGray,
        progress4Color = Signal_red,
        progress1Label = "Offen",
        progress2Label = "Aufgehangen",
        progress3Label = "Abgehangen",
        progress4Label = "Überfällig",
        barHeight = 16
      )
    }
    if (showMaps){
      SpacerBetweenElements()
      map()
    }
  }
}


