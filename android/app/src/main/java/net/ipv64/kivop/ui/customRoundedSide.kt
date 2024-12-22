package net.ipv64.kivop.ui

import androidx.annotation.IntRange
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.drawscope.DrawScope

// Absolute values version
fun Modifier.customRoundedTop(
    color: Color = Color.Blue,
    height: Float = 50f,
    width: Float = 35f
): Modifier = drawBehind { applyCustomRoundedTop(color, -height, width) }

// Percentage values version
fun Modifier.customRoundedTop(
    color: Color = Color.Blue,
    @IntRange(from = 0, to = 100) heightPercent: Int = 0,
    @IntRange(from = 0, to = 50) widthPercent: Int = 0,
    maxHeight: Float = 400f,
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTop(
      color,
      -height,
      width,
  )
}

fun Modifier.customRoundedBottom(
    color: Color = Color.Blue,
    height: Float = 50f,
    width: Float = 35f
): Modifier = drawBehind { applyCustomRoundedTop(color, height, width, size.height) }

// Percentage values version

fun Modifier.customRoundedBottom(
    color: Color = Color.Blue,
    @IntRange(from = 0, to = 100) heightPercent: Int = 0,
    @IntRange(from = 0, to = 50) widthPercent: Int = 0,
    maxHeight: Float = 400f,
): Modifier = drawBehind {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTop(color, height, width, size.height)
}

// Shared implementation logic
private fun DrawScope.applyCustomRoundedTop(
    color: Color,
    height: Float,
    width: Float,
    start: Float = 0f
) {
  val widthLimited = width.coerceAtMost(size.width / 2)

  // Define control points for the cubic Bézier curve
  val point1 = Offset(width, height + start)
  val point2 = Offset(size.width - widthLimited, height + start)

  // Create the path for the rounded top
  val path =
      Path().apply {
        moveTo(0f, start)
        cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, start)
        // lineTo(size.width, size.height)
        // lineTo(0f, size.height)
        close()
      }
  // debug bezier curve points
  // drawPoints(listOf(point1,point2), pointMode = PointMode.Points,Color.Cyan,10f)
  drawPath(path, color)
}
