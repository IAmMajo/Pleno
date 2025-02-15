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

import android.net.Uri
import android.util.Log
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
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
import coil3.compose.AsyncImage
import net.ipv64.kivop.R
import net.ipv64.kivop.services.base64ToBitmap
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Secondary
import net.ipv64.kivop.ui.theme.Text_prime
import net.ipv64.kivop.ui.theme.Text_tertiary

@Composable
fun ImgPicker(
    img: String? = null,
    size: Dp = 150.dp,
    userName: String = "Max",
    edit: Boolean = true,
    onImagePicked: (Uri?) -> Unit
) {
  var selectedImageUri by remember { mutableStateOf<Uri?>(null) }
  val pickMedia =
      rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
        if (uri != null) {
          selectedImageUri = uri
          onImagePicked(uri)
        } else {
          Log.d("PhotoPicker", "No media selected")
        }
      }

  Box(
      modifier =
          Modifier.size(size)
              .customShadow(cornersRadius = 1000.dp)
              .background(Secondary, shape = CircleShape),
  ) {
    if (selectedImageUri != null) {
      AsyncImage(
          model = selectedImageUri,
          contentDescription = "Profile Picture",
          contentScale = ContentScale.Crop,
          modifier = Modifier.align(Alignment.Center).fillMaxSize().clip(shape = CircleShape),
      )
    } else if (img != null) {
      AsyncImage(
          model = base64ToBitmap(img),
          contentDescription = "Profile Picture",
          contentScale = ContentScale.Crop,
          modifier = Modifier.align(Alignment.Center).fillMaxSize().clip(shape = CircleShape),
      )
    } else {
      Text(
          text = userName.first().uppercase(),
          color = Text_prime,
          style = MaterialTheme.typography.headlineLarge,
          fontSize = 64.sp,
          modifier = Modifier.align(Alignment.Center))
    }
    if (edit) {
      Box(
          modifier =
              Modifier.clip(shape = CircleShape)
                  .background(Background_secondary)
                  .size(size * 0.3f)
                  .align(Alignment.BottomEnd)
                  .clickable(
                      onClick = {
                        pickMedia.launch(
                            PickVisualMediaRequest(
                                ActivityResultContracts.PickVisualMedia.ImageOnly))
                      }),
          contentAlignment = Alignment.Center) {
            Icon(
                painter = painterResource(id = R.drawable.ic_edit),
                contentDescription = "Upload Image",
                tint = Text_tertiary,
                modifier = Modifier.fillMaxSize().padding(8.dp))
          }
    }
  }
}
