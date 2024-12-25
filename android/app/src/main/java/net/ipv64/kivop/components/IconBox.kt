package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.rounded.Home
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@Composable
fun IconBox(
  icon: ImageVector,
  height: Dp = 40.dp,
  backgroundColor: Color,
  tint: Color,
  onClick: () -> Unit,
) {
  Box(
    modifier = Modifier.height(height).aspectRatio(1f).clip(RoundedCornerShape(8.dp)).background(backgroundColor).clickable { onClick() }.padding(10.dp),
  ){
    Icon(
      modifier = Modifier.align(Alignment.Center).fillMaxSize(),
      imageVector = icon,
      contentDescription = null,
      tint = tint,
    )
  }
}

@Preview
@Composable
fun IconBoxPreview() {
  IconBox(
    icon = Icons.Rounded.Home,
    backgroundColor = Color.White,
    tint = Color.Black,
    onClick = {})
}
