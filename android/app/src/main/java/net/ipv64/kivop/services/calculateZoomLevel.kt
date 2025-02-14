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

fun calculateZoomLevel(distance: Double): Double {
  val maxZoom = 18.0 // Maximum zoom level (you can adjust based on your needs)
  val minZoom = 2.0 // Minimum zoom level (you can adjust based on your needs)

  // Define the range for zooming (distance in meters)
  val zoomRange = 65000.0 // Maximum distance for minimum zoom (adjust if necessary)

  // Calculate zoom level based on distance
  val zoom = maxZoom - (distance / zoomRange) * (maxZoom - minZoom)

  return zoom.coerceIn(minZoom, maxZoom) // Ensure zoom is within the defined range
}
