package net.ipv64.kivop.components

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.ModalBottomSheetDefaults.properties
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.rememberCameraPositionState
import com.google.maps.android.compose.rememberMarkerState

@Composable
fun MapSingleMarker(markerPosition: LatLng) {
  val markerState = rememberMarkerState(position = markerPosition)
  val cameraPositionState = rememberCameraPositionState {
    position = CameraPosition.fromLatLngZoom(markerPosition, 15f)
  }
  GoogleMap(
      modifier = Modifier.fillMaxSize(),
      cameraPositionState = cameraPositionState,
      properties = MapProperties(),
      uiSettings =
          MapUiSettings(
              zoomControlsEnabled = false,
              zoomGesturesEnabled = false,
              scrollGesturesEnabled = false,
              scrollGesturesEnabledDuringRotateOrZoom = false,
              mapToolbarEnabled = false,
          )) {
        Marker(
            state = markerState,
        )
      }
}
