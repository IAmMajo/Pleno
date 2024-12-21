package net.ipv64.kivop.ui

import android.R.attr.path
import android.util.Log
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawWithCache
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.PointMode
import androidx.compose.ui.graphics.drawscope.Fill
import androidx.compose.ui.graphics.drawscope.Stroke

import net.ipv64.kivop.ui.theme.Primary


fun Modifier.customRoundedTop(
  color: Color = Primary,
  height: Float = 50f,
  width: Float = 35f,
) = drawWithCache {
  var heightLimited = height 
  if (heightLimited > size.height) {
    heightLimited = size.height
  }
  var widthLimited = width
  if (widthLimited > size.width/2) {
    widthLimited = size.width/2
  }
  var point1 = Offset(widthLimited, -heightLimited)
  var point2 = Offset(size.width-widthLimited, -heightLimited)

  var offset = Offset(-(size.width),  -size.height)
  var size = Size(size.width, size.height)
  Log.i("coustomRoundTop", "offset: $offset, size: $size")
  var path = Path()

  path.moveTo(0f, 0f)
  path.cubicTo(point1.x, point1.y, point2.x, point2.y, size.width, 0f)
  onDrawBehind {
    //drawPoints(listOf(point1,point2), pointMode = PointMode.Points,Color.Blue,10f)
    drawPath(path, color, style = Fill)
  }
  }