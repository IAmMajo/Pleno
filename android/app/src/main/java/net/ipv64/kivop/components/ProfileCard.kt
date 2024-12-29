package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
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
import androidx.compose.ui.unit.dp
import com.bumptech.glide.integration.compose.ExperimentalGlideComposeApi
import com.bumptech.glide.integration.compose.GlideImage
import net.ipv64.kivop.services.byteArrayToBitmap
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime

@Composable fun ProfileCard() {}

@OptIn(ExperimentalGlideComposeApi::class)
@Composable
fun ProfileCardSmall(name: String, profilePicture: ByteArray?,role: String,backgroundColor: Color = Background_secondary,texColor: Color = Text_prime ) {
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .height(68.dp)
              .customShadow()
              .background(backgroundColor, shape = RoundedCornerShape(8.dp))
              .padding(8.dp)) {
        Row(modifier = Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
          if (profilePicture != null) {
            GlideImage(
                model = byteArrayToBitmap(profilePicture),
                contentDescription = "Profile Picture",
            )
          } else {
            // Todo: replace with ProfileImgPlaceholder compomnente
            Box(
                modifier =
                    Modifier.fillMaxHeight()
                        .aspectRatio(1f)
                        .clip(shape = CircleShape)
                        .background(Signal_blue)) {
                  Text(
                      text = name[0].toString().uppercase(),
                      modifier = Modifier.align(Alignment.Center),
                      style = MaterialTheme.typography.headlineLarge,
                      color = Background_secondary)
                }
          }
          Spacer(modifier = Modifier.size(16.dp))
          Column() {
            Text(text = name, style = MaterialTheme.typography.labelLarge, color = texColor)
            Text(
                text = role,
                style = MaterialTheme.typography.labelLarge,
                color = texColor.copy(alpha = 0.40f))
          }
        }
      }
}
