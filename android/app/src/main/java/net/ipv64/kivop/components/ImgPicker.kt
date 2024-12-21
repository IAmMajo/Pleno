package net.ipv64.kivop.components

import android.net.Uri
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.bumptech.glide.integration.compose.ExperimentalGlideComposeApi
import com.bumptech.glide.integration.compose.GlideImage
import net.ipv64.kivop.R
import net.ipv64.kivop.services.byteArrayToBitmap
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@OptIn(ExperimentalGlideComposeApi::class)
@Composable
fun ImgPicker(img: ByteArray? = null, size: Dp = 150.dp): Uri? {
  var selectedImageUri by remember { mutableStateOf<Uri?>(null) }

  val launcher =
      rememberLauncherForActivityResult(contract = ActivityResultContracts.GetContent()) { uri: Uri?
        ->
        selectedImageUri = uri
        Log.i("URI", uri.toString())
      }

  Box(
      modifier = Modifier.size(size).background(Secondary, shape = CircleShape),
  ) {
    if (img != null) {
      GlideImage(
          model = byteArrayToBitmap(img),
          contentDescription = "Profile Picture",
          contentScale = ContentScale.Crop,
          modifier = Modifier.align(Alignment.Center).fillMaxSize().clip(shape = CircleShape),
      )
    } else if (selectedImageUri != null) {
      GlideImage(
          model = selectedImageUri,
          contentDescription = "Profile Picture",
          contentScale = ContentScale.Crop,
          modifier = Modifier.align(Alignment.Center).fillMaxSize().clip(shape = CircleShape),
      )
    } else {
      Text(
          text = "M",
          color = Text_prime,
          style = MaterialTheme.typography.headlineLarge,
          fontSize = 64.sp,
          modifier = Modifier.align(Alignment.Center))
    }
    Box(
        modifier =
            Modifier.clip(shape = CircleShape)
                .background(Background_secondary)
                .size(size * 0.3f)
                .align(Alignment.BottomEnd)
                .clickable(onClick = { launcher.launch("image/*") }),
        contentAlignment = Alignment.Center) {
          Icon(
              painter = painterResource(id = R.drawable.ic_edit),
              contentDescription = "Upload Image",
              tint = Text_tertiary,
              modifier = Modifier.fillMaxSize().padding(8.dp))
        }
  }
  return selectedImageUri
}
