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

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.services.base64ToBitmap
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Signal_blue
import net.ipv64.kivop.ui.theme.Text_prime

@Composable fun ProfileCard() {}

@Composable
fun ProfileCardSmall(
    name: String,
    profilePicture: String?,
    role: String,
    backgroundColor: Color = Background_secondary,
    texColor: Color = Text_prime,
    onClick: () -> Unit
) {
  Box(
      modifier =
          Modifier.fillMaxWidth()
              .height(68.dp)
              .clip(shape = RoundedCornerShape(8.dp))
              .clickable { onClick() }
              .customShadow()
              .background(backgroundColor)
              .padding(8.dp)) {
        Row(modifier = Modifier.fillMaxSize(), verticalAlignment = Alignment.CenterVertically) {
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
