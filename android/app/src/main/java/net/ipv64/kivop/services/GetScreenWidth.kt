package net.ipv64.kivop.services

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalConfiguration
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun GetScreenWidth(): Dp {
  val configuration = LocalConfiguration.current
  val density = LocalDensity.current
  return with(density) { configuration.screenWidthDp.dp }
}
