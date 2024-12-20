package net.ipv64.kivop.ui

/*
Copyright 2020 Cedric Kring.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
    
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp


fun Modifier.customShadow(
  color: Color = Color(272626),
  alpha: Float = 0.08f,
  cornersRadius: Dp = 8.dp,
  shadowBlurRadius: Dp = 16.dp,
  offsetY: Dp = 4.dp,
  offsetX: Dp = 0.dp
) = drawBehind {

  val shadowColor = color.copy(alpha = alpha).toArgb()
  val transparentColor = color.copy(alpha = 0f).toArgb()

  drawIntoCanvas {
    val paint = Paint()
    val frameworkPaint = paint.asFrameworkPaint()
    frameworkPaint.color = transparentColor
    frameworkPaint.setShadowLayer(
      shadowBlurRadius.toPx(),
      offsetX.toPx(),
      offsetY.toPx(),
      shadowColor
    )
    it.drawRoundRect(
      0f,
      0f,
      this.size.width,
      this.size.height,
      cornersRadius.toPx(),
      cornersRadius.toPx(),
      paint
    )
  }
}

