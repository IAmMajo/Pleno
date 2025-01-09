package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun IconBox(
  icon: ImageVector,
  height: Dp = 40.dp,
  backgroundColor: Color,
  tint: Color,
) {
  Box(
    modifier =
    Modifier.height(height)
      .aspectRatio(1f)
      .clip(RoundedCornerShape(8.dp))
      .background(backgroundColor)
      .padding(10.dp),
  ) {
    Icon(
      modifier = Modifier.align(Alignment.Center).fillMaxSize(),
      imageVector = icon,
      contentDescription = null,
      tint = tint,
    )
  }
}