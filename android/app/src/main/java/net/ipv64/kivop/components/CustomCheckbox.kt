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

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Checkbox_background
import net.ipv64.kivop.ui.theme.Primary

@Composable
fun CustomCheckbox(
    modifier: Modifier = Modifier,
    size: Dp = 40.dp,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
  val alpha by
      animateFloatAsState(
          targetValue = if (checked) 1f else 0f, animationSpec = tween(durationMillis = 500))

  Box(
      modifier =
          modifier
              .size(size)
              .clickable { onCheckedChange(!checked) }
              .background(Checkbox_background, shape = RoundedCornerShape(8.dp)),
      // Toggle on click
      contentAlignment = Alignment.Center) {
        if (checked) {
          val iconSize = size - 10.dp
          Icon(
              painter = painterResource(R.drawable.ic_check),
              contentDescription = "Checked",
              modifier = Modifier.size(iconSize).graphicsLayer(alpha = alpha),
              tint = Primary // Checkmark color when checked
              )
        }
      }
}
