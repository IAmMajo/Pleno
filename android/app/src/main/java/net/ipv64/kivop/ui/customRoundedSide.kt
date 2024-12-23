package net.ipv64.kivop.ui

import androidx.annotation.IntRange
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Paint
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.asAndroidPath
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp


// Percentage values version
fun Modifier.customRoundedTop(
    color: Color = Color.Blue,
    @IntRange(from = 0, to = 100) heightPercent: Int = 40,
    @IntRange(from = 0, to = 50) widthPercent: Int = 30,
    maxHeight: Float = 400f,
    heightOffset: Dp = 0.dp,
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTop(color, -height, width, heightOffset = -heightOffset)
}

fun Modifier.customRoundedTopWithShadow(
  color: Color = Color.Blue,
  shadowColor: Color = Color(0xFF272626),
  @IntRange(from = 0, to = 100) heightPercent: Int = 40,
  @IntRange(from = 0, to = 50) widthPercent: Int = 30,
  maxHeight: Float = 400f,
  heightOffset: Dp = 0.dp,
  alpha: Float = 0.25f,
  offsetY: Dp = 4.dp,
  offsetX: Dp = 0.dp
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTopWithShadow(
    color,
    -height,
    width,
    0f,
    heightOffset,
    shadowColor,
    alpha,
    offsetY,
    offsetX
  )
}


// Percentage values version
fun Modifier.customRoundedBottom(
  color: Color = Color.Blue,
  @IntRange(from = 0, to = 100) heightPercent: Int = 40,
  @IntRange(from = 0, to = 50) widthPercent: Int = 30,
  maxHeight: Float = 400f,
  heightOffset: Dp = 0.dp,
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTop(color, height, width, size.height,heightOffset = heightOffset)
}

// Percentage values version
fun Modifier.customRoundedBottomWithShadow(
  color: Color = Color.Blue,
  shadowColor: Color = Color(0xFF272626),
  @IntRange(from = 0, to = 100) heightPercent: Int = 40,
  @IntRange(from = 0, to = 50) widthPercent: Int = 30,
  maxHeight: Float = 400f,
  heightOffset: Dp = 0.dp,
  alpha: Float = 0.25f,
  offsetY: Dp = 4.dp,
  offsetX: Dp = 0.dp
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTopWithShadow(
    color, 
    height, 
    width, 
    size.height,
    heightOffset,
    shadowColor,
    alpha,
    offsetY,
    offsetX
  )
}

private fun DrawScope.applyCustomRoundedTop(
  color: Color,
  height: Float,
  width: Float,
  start: Float = 0f,
  heightOffset: Dp = 0.dp
) {
  val widthLimited = width.coerceAtMost(size.width / 2)

  // Define control points for the cubic Bézier curve
  val point1 = Offset(width, height + start)
  val point2 = Offset(size.width - widthLimited, height + start)
  
  // Create the path for the rounded top
  val path =
    Path().apply {
      moveTo(0f, start)
      if (heightOffset != 0.dp) {
        lineTo(0f, start+heightOffset.toPx())
        cubicTo(point1.x, point1.y+heightOffset.toPx(), point2.x, point2.y+heightOffset.toPx(), size.width, start+heightOffset.toPx())
        lineTo(size.width,start)
      }else{
        cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, start)
      }
      close()
    }
    drawPath(path, color)
}

// Shared implementation logic
private fun DrawScope.applyCustomRoundedTopWithShadow(
    color: Color,
    height: Float,
    width: Float,
    start: Float = 0f,
    heightOffset: Dp = 0.dp,
    shadowColor: Color = Color(0xFF272626),
    alpha: Float = 0.08f,
    shadowBlurRadius: Dp = 16.dp,
    offsetY: Dp = 4.dp,
    offsetX: Dp = 0.dp
) {
  val widthLimited = width.coerceAtMost(size.width / 2)

  // Define control points for the cubic Bézier curve
  val point1 = Offset(width, height + start)
  val point2 = Offset(size.width - widthLimited, height + start)

  val shadowColorAlpha = shadowColor.copy(alpha = alpha).toArgb()
  val transparentColor = shadowColor.copy(alpha = 0f).toArgb()

  val paint = Paint()
  val frameworkPaint = paint.asFrameworkPaint()
  frameworkPaint.color = transparentColor
  frameworkPaint.setShadowLayer(
    shadowBlurRadius.toPx(), offsetY.toPx(), offsetX.toPx(), shadowColorAlpha)
  
  // Create the path for the rounded top
  val path =
      Path().apply {
        moveTo(0f, start)
        if (heightOffset != 0.dp) {
          lineTo(0f, start+heightOffset.toPx())
          cubicTo(point1.x, point1.y+heightOffset.toPx(), point2.x, point2.y+heightOffset.toPx(), size.width, start+heightOffset.toPx())
          lineTo(size.width,start)
        }else{
          cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, start)
        }
        close()
      }
  
  drawIntoCanvas {canvas ->
    canvas.nativeCanvas.drawPath(path.asAndroidPath(), frameworkPaint)
  }

  drawPath(path, color)
}
