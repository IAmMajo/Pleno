package net.ipv64.kivop.services

import androidx.compose.ui.graphics.Color

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
