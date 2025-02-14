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
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.ui.theme.Background_prime
import net.ipv64.kivop.ui.theme.Primary

@Composable
fun Label(
    backgroundColor: Color = Color(color = 0xff686D74),
    content: @Composable BoxScope.() -> Unit
) {
  Box(
      modifier =
          Modifier.wrapContentWidth()
              .clip(RoundedCornerShape(50))
              .background(backgroundColor)
              .padding(horizontal = 18.dp, vertical = 6.dp),
      content = content)
}

@Composable
fun LabelMax(
    modifier: Modifier = Modifier,
    outerBackgroundColor: Color = Color.Transparent, // Hintergrund um die Box
    backgroundColor: Color = Color(0xFF686D74), // Hintergrund der Box selbst
    onClick: (() -> Unit)? = null, // Optionaler onClick-Parameter
    content: @Composable BoxScope.() -> Unit
) {
  Box(modifier = modifier.fillMaxWidth().background(outerBackgroundColor)) {
    Box(
        modifier =
            Modifier.fillMaxWidth()
                .clip(RoundedCornerShape(50))
                .then(
                    if (onClick != null) Modifier.clickable { onClick() }
                    else Modifier) // Optionaler Klick
                .background(backgroundColor) // Hintergrund der Box
                .padding(horizontal = 18.dp, vertical = 6.dp),
        content = content)
  }
}

@Preview(showBackground = true)
@Composable
fun LabelMaxPreview() {
  LabelMax(outerBackgroundColor = Primary) {
    Text(
        text = "Nach rechts ausgerichtet",
        color = Background_prime,
        style = MaterialTheme.typography.bodyMedium)
  }
}
