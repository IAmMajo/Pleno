// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

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
