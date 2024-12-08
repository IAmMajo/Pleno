package com.example.kivopandriod.components

import android.graphics.Paint
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.drawBehind
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.drawscope.DrawScope
import androidx.compose.ui.graphics.nativeCanvas
import androidx.compose.ui.unit.dp
import com.example.kivopandriod.moduls.VotingResults
import com.example.kivopandriod.ui.theme.Secondary_dark
import kotlin.math.*

@Composable
fun PieChart(list: List<VotingResults>, explodeDistance: Float = 30f) {
  Column(
      modifier =
          Modifier.fillMaxWidth()
              .background(Secondary_dark, shape = RoundedCornerShape(8.dp))
              .padding(15.dp),
      horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier =
                Modifier.fillMaxWidth().aspectRatio(1f).drawBehind {
                  drawPieChart(
                      list.sortedByDescending { it.votes }, explodeDistance = explodeDistance)
                }) {}
      }
}

val CakeColorStart = Color(0xFF2C7D91)
val CakeColorEnd = Color(0xFFF7DEC8)

fun DrawScope.drawPieChart(list: List<VotingResults>, explodeDistance: Float) {
  val totalVotes = list.sumOf { it.votes }
  val colors: List<Color> = interpolateColor(CakeColorStart, CakeColorEnd, list.size)
  // startingAngle -90° to start at the top
  var startingAngle: Float = -90.0f

  // adjust size of chart to keep it in bound -- takes away the explode distance from each side
  val adjustedSize =
      size.copy(
          width = size.width - explodeDistance * 2, height = size.height - explodeDistance * 2)
  // offset to keep the chart in bound
  val offset = Offset(explodeDistance, explodeDistance)
  // set textPaint
  val textPaint =
      Paint().apply {
        color = android.graphics.Color.WHITE
        textSize = 60f
        textAlign = Paint.Align.CENTER
      }

  for (i in list.indices) {
    // calc sweep angle percentage of total votes
    val sweepAngle = calcSweepAngle(list[i].votes, totalVotes)
    // calc explodeOffset. How much each slice is moved from the center
    val explodeOffset = calcPointOnCircle(startingAngle, sweepAngle, explodeDistance)
    drawArc(
        colors[i],
        startingAngle,
        sweepAngle,
        true,
        topLeft = offset.copy(x = offset.x + explodeOffset.x, y = offset.y + explodeOffset.y),
        size = adjustedSize)

    // radius of the circle adjustedSize = diameter
    val radius = size.width / 2
    // find Text offset 1/3
    val textOffset = calcPointOnCircle(startingAngle, sweepAngle, adjustedSize.width / 3)
    // calc text position by taking the center and add the offset from textOffset
    val textPos = Offset(radius, radius) + textOffset
    // estimate the width of the arc
    val sliceWidth = (sweepAngle / 360) * (2 * Math.PI * radius).toFloat() * 0.5f
    // set text name
    val textName = list[i].label
    // calc set percentage
    val textPercentage = ((list[i].votes * 100) / totalVotes).toString() + "%"
    // get the text name width
    val textWidth = textPaint.measureText(textName)
    // check if the text fits in the slice
    if (textWidth < sliceWidth) {
      // draw name
      drawContext.canvas.nativeCanvas.drawText(textName, textPos.x, textPos.y, textPaint)
      // draw percentage under name
      val textPercentageOffsetY = textPaint.textSize * 1.1f
      drawContext.canvas.nativeCanvas.drawText(
          textPercentage, textPos.x, textPos.y + textPercentageOffsetY, textPaint)
    }

    startingAngle += sweepAngle
  }
}

fun calcSweepAngle(votes: Int, totalVotes: Int): Float {
  // votes in percentage for the sweep angle
  return 360 * (votes.toFloat() / totalVotes)
}

// calc the explode offset(offset of starting point)
fun calcPointOnCircle(startingAngle: Float, sweepAngle: Float, explodeDistance: Float): Offset {
  // mid point of the slice on the outside
  val explodeAngle = startingAngle + sweepAngle / 2
  // calc the x and y offset by calculation the point on a circle with the radius of the explode
  // distance
  val offsetX = cos(Math.toRadians(explodeAngle.toDouble())).toFloat() * explodeDistance
  val offsetY = sin(Math.toRadians(explodeAngle.toDouble())).toFloat() * explodeDistance
  return Offset(offsetX, offsetY)
}

// just a test for coloring each slice
fun interpolateColor(startColor: Color, endColor: Color, steps: Int): List<Color> {
  val startRed = startColor.red * 255
  val startGreen = startColor.green * 255
  val startBlue = startColor.blue * 255

  val endRed = endColor.red * 255
  val endGreen = endColor.green * 255
  val endBlue = endColor.blue * 255

  val colors = mutableListOf<Color>()
  val redDiff = (endRed - startRed) / (steps - 1)
  val greenDiff = (endGreen - startGreen) / (steps - 1)
  val blueDiff = (endBlue - startBlue) / (steps - 1)

  for (i in 0 until steps) {
    val red = (startRed + redDiff * i).toInt()
    val green = (startGreen + greenDiff * i).toInt()
    val blue = (startBlue + blueDiff * i).toInt()

    colors.add(Color(red = red / 255f, green = green / 255f, blue = blue / 255f))
  }

  return colors
}
