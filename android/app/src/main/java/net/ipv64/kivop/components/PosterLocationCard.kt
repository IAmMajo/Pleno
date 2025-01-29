package net.ipv64.kivop.components

import android.graphics.BitmapFactory
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.material3.TextField
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
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
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.dtos.PosterServiceDTOs.ResponsibleUsersDTO
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Primary
import net.ipv64.kivop.ui.theme.Primary_20
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_prime70
import java.time.LocalDateTime
import java.util.UUID
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi


@OptIn(ExperimentalEncodingApi::class)
@Composable
fun PosterLocationCard(
  poster: PosterPositionResponseDTO,
  address: String? = null,
  onClick: () -> Unit) {
  val base64ImageByteArray = remember {mutableStateOf<ByteArray?>(null)}
  LaunchedEffect(poster.image) {
    withContext(Dispatchers.IO) {
      val decodedImage = poster.image?.substringAfter("base64")?.let { Base64.decode(it) }
      base64ImageByteArray.value = decodedImage
    }
  }
  
  Box(
    modifier = Modifier
      .fillMaxWidth()
      .customShadow()
      .clip(RoundedCornerShape(8.dp))
      .clickable { onClick() }
      .background(Background_secondary)
      .padding(8.dp)
  ){
    Column { 
      Row(
        verticalAlignment = Alignment.CenterVertically,
      ) {
        if (poster.image == null) {
          IconBox(
            icon = ImageVector.vectorResource(R.drawable.ic_image),
            height = 80.dp,
            backgroundColor = Primary_20,
            tint = Primary
          )
        }else{
          AsyncImage(
            model = base64ImageByteArray.value,
            contentDescription = null,
            contentScale= ContentScale.Crop,
            modifier = Modifier
              .clip(shape = RoundedCornerShape(8.dp))
              .width(80.dp)
              .aspectRatio(1f)
              .background(Color.LightGray),
          )
        }
        SpacerBetweenElements(8.dp)
        Column {
          if (address != null) {
            Text(
              text = address.replaceAfter(',',"").trim(','),
              color = Text_prime,
              style = TextStyles.subHeadingStyle)
            Text(
              text = address.replaceBefore(',',"").trim(','),
              color = Text_prime70,
              style = TextStyles.largeContentStyle)
          }
        }
      }
      Row { 
        
      }
    }
  }
}

@Preview
@Composable
fun PosterLocationCardPreview() {
  PosterLocationCard(
    poster = PosterPositionResponseDTO(
      id = UUID.randomUUID(),
      posterId = null,
      latitude = 0.0,
      longitude = 0.0,
      postedBy = null,
      postedAt = null,
      expiresAt = LocalDateTime.now(),
      removedBy = null,
      removedAt = null,
      image = null,
      responsibleUsers = List(
        size = 3,
        init = { ResponsibleUsersDTO(UUID.randomUUID(), "Test") }
      ),
      status = PosterPositionStatus.toHang,
    ),
    address = "Teststraße 1, test",
    onClick = {}
  )
}