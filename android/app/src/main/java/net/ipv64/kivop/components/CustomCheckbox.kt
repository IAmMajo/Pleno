package net.ipv64.kivop.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.tween
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import net.ipv64.kivop.R
import net.ipv64.kivop.ui.theme.Checkbox_background
import net.ipv64.kivop.ui.theme.Primary

import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp

@Composable
fun CustomCheckbox(
  modifier: Modifier = Modifier,
  size: Dp = 40.dp,
  checked: Boolean,
  onCheckedChange: (Boolean) -> Unit
) {
  val alpha by animateFloatAsState(
    targetValue = if (checked) 1f else 0f,
    animationSpec = tween(durationMillis = 500)
  )

  Box(
    modifier = modifier
      .size(size)
      .clickable { onCheckedChange(!checked) }
      .background(Checkbox_background, shape = RoundedCornerShape(8.dp)),
        // Toggle on click
    contentAlignment = Alignment.Center
  ) {
    if (checked) {
      val iconSize = size - 10.dp
      Icon(
        painter = painterResource(R.drawable.ic_check),
        contentDescription = "Checked",
        modifier = Modifier
          .size(iconSize)
          .graphicsLayer(alpha = alpha),
        tint = Primary  // Checkmark color when checked
      )
    }
  }
}

