package net.ipv64.kivop.ui

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

fun Modifier.customShadow(
  elevation: Dp = 4.dp,
  cornerRadius: Dp = 8.dp,
): Modifier = this.shadow(
  elevation = elevation,
  shape = RoundedCornerShape(cornerRadius)
)