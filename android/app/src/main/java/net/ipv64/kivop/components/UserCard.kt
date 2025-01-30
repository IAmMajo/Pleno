package net.ipv64.kivop.components

import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

@OptIn(ExperimentalEncodingApi::class)
@Composable
fun UserCard(
  name: String,
  image: String? = null,
  backgroundColor: Color = Color.Transparent,
  extraContent: @Composable () -> Unit = {}
) {
  //Format image string
  val base64ImageByteArray = remember { mutableStateOf<ByteArray?>(null) }
  LaunchedEffect(image) {
    withContext(Dispatchers.IO) {
      if (image != null){
        val decodedImage = image.substringAfter("base64").let { Base64.decode(it) }
        base64ImageByteArray.value = decodedImage
      }
    }
  }
  Row(
    modifier = Modifier.fillMaxWidth().clip(shape = RoundedCornerShape(8.dp)).background(backgroundColor).padding(6.dp),
    verticalAlignment = Alignment.CenterVertically
  ) {
    val initial = name.firstOrNull()?.toString() ?: ""
    Box(
      contentAlignment = Alignment.Center,
      modifier = Modifier.size(40.dp).clip(CircleShape).background(Color(0xFF1061DA))
    ){
      if (image == null) {
        Text(
          text = initial,
          color = Background_prime,
          fontSize = 18.sp,
          style = TextStyles.contentStyle,
          fontWeight = FontWeight.Bold
        )
      }else{
        AsyncImage(
          model = base64ImageByteArray.value,
          contentDescription = null,
          modifier = Modifier.size(40.dp).clip(CircleShape).background(Color(0xFF1061DA))
        )
      }
    }
    Spacer(modifier = Modifier.width(5.dp))
    Text(
      text = name,
      color = Text_prime,
      modifier = Modifier.weight(1f),
      style = TextStyles.largeContentStyle,
    )
    Spacer(modifier = Modifier.weight(1f))
    extraContent()
  }
}

@Preview
@Composable
fun UserCardPreview() {
  UserCard(name = "John Doe", backgroundColor = Color.Red, extraContent = {})
}