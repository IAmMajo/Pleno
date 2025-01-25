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
