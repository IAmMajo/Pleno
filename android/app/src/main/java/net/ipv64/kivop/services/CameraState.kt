package net.ipv64.kivop.services

import androidx.compose.runtime.saveable.Saver
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.saveable.listSaver
import com.utsman.osmandcompose.CameraProperty
import com.utsman.osmandcompose.CameraState
import org.osmdroid.util.GeoPoint

// Define a custom saver for CameraState
val cameraStateSaver = Saver<CameraState, List<Double>>(
  save = { cameraState ->
    // Save essential properties (e.g., geoPoint latitude, longitude, and zoom level)
    val geoPoint = cameraState.geoPoint
    listOf(geoPoint.latitude, geoPoint.longitude, cameraState.zoom)
  },
  restore = { savedState ->
    // Restore the CameraState from saved values
    val latitude = savedState[0]
    val longitude = savedState[1]
    val zoom = savedState[2]

    // Create a CameraProperty from the saved state
    val geoPoint = GeoPoint(latitude, longitude)
    val cameraProperty = CameraProperty(geoPoint, zoom)

    CameraState(cameraProperty)
  }
)

