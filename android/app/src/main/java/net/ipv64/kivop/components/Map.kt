package net.ipv64.kivop.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableDoubleStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.clipToBounds
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.core.content.ContextCompat
import com.utsman.osmandcompose.CameraProperty
import com.utsman.osmandcompose.CameraState
import com.utsman.osmandcompose.DefaultMapProperties
import com.utsman.osmandcompose.Marker
import com.utsman.osmandcompose.MarkerState
import com.utsman.osmandcompose.OpenStreetMap
import com.utsman.osmandcompose.ZoomButtonVisibility
import kotlinx.coroutines.delay
import net.ipv64.kivop.R
import net.ipv64.kivop.services.calculateZoomLevel
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint

// TODO: bugged Look for alternative - not getting updated
@Composable
fun OsmdroidMapView(
    startLocation: GeoPoint?,
    destinationLocation: GeoPoint?,
    currentLocation: GeoPoint? = null
) {
  val context = LocalContext.current

  val startMarker = remember { MarkerState(startLocation ?: GeoPoint(0.1, 0.1)) }
  val destinationMarker = remember { MarkerState(destinationLocation ?: GeoPoint(0.1, 0.1)) }

  val zoomLevelState = remember { mutableDoubleStateOf(18.0) }

  // Remember camera state, but without using saveable state registry
  val cameraState = remember {
    val initialGeoPoint = currentLocation ?: GeoPoint(0.0, 0.0)
    val initialZoom = 18.0
    val cameraProperty = CameraProperty(initialGeoPoint, initialZoom)
    CameraState(cameraProperty)
  }

  // Handle start location updates
  LaunchedEffect(startLocation) {
    if (startLocation != null) {
      // Stop any previous animation
      cameraState.stopAnimation(jumpToFinish = true)
      startMarker.geoPoint = startLocation
      if (destinationLocation == null) {
        cameraState.animateTo(startLocation, zoomLevelState.value)
      }
    } else {
      // Reset marker when location is null
      startMarker.geoPoint = GeoPoint(0.0, 0.0)
    }
  }

  // Handle destination location updates
  LaunchedEffect(destinationLocation) {
    if (destinationLocation != null) {
      // Stop any previous animation
      cameraState.stopAnimation(jumpToFinish = true)
      destinationMarker.geoPoint = destinationLocation
      if (startLocation == null) {
        cameraState.animateTo(destinationLocation, zoomLevelState.value)
      }
    } else {
      // Reset marker when location is null
      destinationMarker.geoPoint = GeoPoint(0.0, 0.0)
    }
  }

  // Adjust the camera when both markers are present
  LaunchedEffect(startLocation, destinationLocation) {
    if (startLocation != null && destinationLocation != null) {
      cameraState.stopAnimation(jumpToFinish = true)

      val distance = startLocation.distanceToAsDouble(destinationLocation)
      val newZoom = calculateZoomLevel(distance)

      if (newZoom != zoomLevelState.value) { // Prevent unnecessary recompositions
        zoomLevelState.value = newZoom
        val midpoint =
            GeoPoint(
                (startLocation.latitude + destinationLocation.latitude) / 2,
                (startLocation.longitude + destinationLocation.longitude) / 2)

        cameraState.animateTo(midpoint, newZoom)
        delay(2000)
        cameraState.zoom = newZoom
      }
    }
  }

  // Map properties (e.g., to disable gestures and zoom buttons)
  val mapProperties =
      DefaultMapProperties.copy(
          isTilesScaledToDpi = false,
          tileSources = TileSourceFactory.DEFAULT_TILE_SOURCE,
          isEnableRotationGesture = false,
          zoomButtonVisibility = ZoomButtonVisibility.NEVER)

  Box(
      modifier =
          Modifier.width(500.dp)
              .aspectRatio(1.5f)
              .clip(RoundedCornerShape(8.dp))
              .background(Color.White)) {
        OpenStreetMap(
            modifier = Modifier.fillMaxSize().clipToBounds(),
            cameraState = cameraState,
            properties = mapProperties) {
              val startIcon = ContextCompat.getDrawable(context, R.drawable.ic_place)
              val destinationIcon = ContextCompat.getDrawable(context, R.drawable.ic_flag)

              // Place start marker if location is provided
              startLocation?.let { Marker(title = "Start", icon = startIcon, state = startMarker) }

              // Place destination marker if location is provided
              destinationLocation?.let {
                Marker(title = "Destination", icon = destinationIcon, state = destinationMarker)
              }
            }
      }
}
