package net.ipv64.kivop.ui

import android.R.attr.path
import android.util.Log
import androidx.annotation.IntRange
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.DrawResult
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.draw.drawWithContent
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PointMode
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.drawscope.drawIntoCanvas

import net.ipv64.kivop.ui.theme.Primary


//// Absolute values version
//fun Modifier.customRoundedTop(
//  color: Color = Primary,
//  height: Float = 50f,
//  width: Float = 35f,
//) {
//  var heightLimited = height 
//  if (heightLimited > size.height) {
//    heightLimited = size.height
//  }
//  var widthLimited = width
//  if (widthLimited > size.width/2) {
//    widthLimited = size.width/2
//  }
//  drawRoundedTop()
//}
//// Percentage values version
//fun Modifier.customRoundedTop(
//  color: Color = Primary,
//  @IntRange(from = 0, to = 100) heightPercent: Int = 0,
//  @IntRange(from = 0, to = 100) widthPercent: Int = 0
//) = drawWithCache {
//  
//}
//
//private fun DrawScope.drawRoundedTop(){
//  var point1 = Offset(widthLimited, -heightLimited)
//  var point2 = Offset(size.width-widthLimited, -heightLimited)
//
//  var offset = Offset(-(size.width),  -size.height)
//  var size = Size(size.width, size.height)
//  Log.i("coustomRoundTop", "offset: $offset, size: $size")
//  var path = Path()
//
//  path.moveTo(0f, 0f)
//  path.cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, 0f)
//  //drawPoints(listOf(point1,point2), pointMode = PointMode.Points,Color.Blue,10f)
//  drawPath(path, color, style = Fill)
//}

// Absolute values version
fun Modifier.customRoundedTop(
  color: Color = Color.Blue,
  height: Float = 50f,
  width: Float = 35f
): Modifier = drawBehind {
  applyCustomRoundedTop(color, height, width)
}

// Percentage values version
fun Modifier.customRoundedTop(
  color: Color = Color.Blue,
  @IntRange(from = 0, to = 100) heightPercent: Int = 0,
  @IntRange(from = 0, to = 50) widthPercent: Int = 0,
  maxHeight: Float = 400f,
): Modifier = drawBehind  {
  val height = maxHeight * (heightPercent / 100f)
  val width = size.width * (widthPercent / 100f)
  applyCustomRoundedTop(color, height, width)
}

// Shared implementation logic
private fun DrawScope.applyCustomRoundedTop(color: Color, height: Float, width: Float) {
  val widthLimited = width.coerceAtMost(size.width / 2)

  // Define control points for the cubic Bézier curve
  val point1 = Offset(widthLimited, -height)
  val point2 = Offset(size.width - widthLimited, -height)

  // Create the path for the rounded top
  val path = Path().apply {
    moveTo(0f, 0f)
    cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, 0f)
    lineTo(size.width, size.height)
    lineTo(0f, size.height)
    close()
  }
    drawPath(path, color)
}