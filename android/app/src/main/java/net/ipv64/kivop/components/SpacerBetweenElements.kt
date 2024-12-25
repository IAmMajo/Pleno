package net.ipv64.kivop.components

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

@Composable
fun SpacerBetweenElements(
  dp: Dp = 16.dp
) {
  Spacer(modifier = Modifier.size(dp))
}
