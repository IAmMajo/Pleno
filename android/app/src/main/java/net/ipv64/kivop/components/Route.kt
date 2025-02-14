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
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.vectorResource
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.customShadow
import net.ipv64.kivop.ui.theme.Background_secondary
import net.ipv64.kivop.ui.theme.Tertiary
import net.ipv64.kivop.ui.theme.TextStyles
import net.ipv64.kivop.ui.theme.Text_prime

@Composable
fun Route(
    startAddress: String,
    destinationAddress: String,
    textStyle: TextStyle = TextStyles.largeContentStyle,
) {
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .customShadow()
              .background(Background_secondary, shape = RoundedCornerShape(8.dp))
              .padding(10.dp),
  ) {
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
      IconBox(
          icon = ImageVector.vectorResource(R.drawable.ic_place),
          height = 50.dp,
          backgroundColor = Tertiary.copy(0.2f),
          tint = Tertiary,
      )
      Spacer(Modifier.size(12.dp))
      Text(text = startAddress, color = Text_prime, style = textStyle)
    }
    IconBox(
        icon = ImageVector.vectorResource(R.drawable.ic_double_arrow_down),
        height = 50.dp,
        backgroundColor = Color.Transparent,
        tint = Tertiary,
    )
    Row(modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
      IconBox(
          icon = ImageVector.vectorResource(R.drawable.ic_flag),
          height = 50.dp,
          backgroundColor = Tertiary.copy(0.2f),
          tint = Tertiary,
      )
      Spacer(Modifier.size(12.dp))
      Text(text = destinationAddress, color = Text_prime, style = textStyle)
    }
  }
}

@Preview
@Composable
fun PreviewRoute() {
  Route(
      startAddress = "Start Adresse",
      destinationAddress = "Ziel Adresse",
  )
}
