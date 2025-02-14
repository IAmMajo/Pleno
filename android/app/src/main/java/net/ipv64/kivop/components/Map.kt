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

package net.ipv64.kivop.components

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.GoogleMap
import com.google.maps.android.compose.MapProperties
import com.google.maps.android.compose.MapUiSettings
import com.google.maps.android.compose.Marker
import com.google.maps.android.compose.MarkerState
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

@Composable
fun MapDoubleMarker(
    modifier: Modifier = Modifier,
    markerPositionStart: LatLng,
    markerPositionEnd: LatLng
) {
  val markerStateStart = rememberMarkerState(position = markerPositionStart)
  val markerStateEnd = rememberMarkerState(position = markerPositionEnd)
  val cameraPositionState = rememberCameraPositionState {
    position = CameraPosition.fromLatLngZoom(markerPositionStart, 15f)
  }
  // Set bounds for camera with Start and Destination coordinates. aka sets camera to fit all
  // markers with a padding of 130
  LaunchedEffect(markerStateStart, markerStateEnd) {
    val bounds =
        LatLngBounds.builder().include(markerPositionStart).include(markerPositionEnd).build()

    cameraPositionState.animate(
        update = CameraUpdateFactory.newLatLngBounds(bounds, 130),
    )
  }

  GoogleMap(
      modifier = Modifier.fillMaxSize().then(modifier),
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
            title = "Start",
            state = markerStateStart,
        )
        Marker(
            title = "Ziel",
            state = markerStateEnd,
        )
      }
}

@Composable
fun MapDynamicTwoMarker(
    modifier: Modifier = Modifier,
    markerPositionStart: LatLng?,
    markerPositionEnd: LatLng?,
    currentLocation: LatLng
) {
  val cameraPositionState = rememberCameraPositionState {
    position = CameraPosition.fromLatLngZoom(currentLocation, 15f)
  }

  val mapSize = remember { mutableStateOf(IntSize(0, 0)) } // Track map dimensions

  val markerStateStart = remember { mutableStateOf<MarkerState?>(null) }
  val markerStateEnd = remember { mutableStateOf<MarkerState?>(null) }

  LaunchedEffect(markerPositionStart) {
    markerStateStart.value = markerPositionStart?.let { MarkerState(position = it) }
    if (markerPositionStart != null && markerPositionEnd == null) {
      cameraPositionState.animate(
          update = CameraUpdateFactory.newLatLng(markerPositionStart), durationMs = 1000)
    }
  }
  LaunchedEffect(markerPositionEnd) {
    markerStateEnd.value = markerPositionEnd?.let { MarkerState(position = it) }
    if (markerPositionEnd != null && markerPositionStart == null) {
      cameraPositionState.animate(
          update = CameraUpdateFactory.newLatLng(markerPositionEnd), durationMs = 1000)
    }
  }

  Box(
      modifier =
          Modifier.fillMaxSize().onSizeChanged { newSize ->
            mapSize.value = newSize
          } // Capture map size
      ) {
        GoogleMap(
            modifier = Modifier.fillMaxSize().then(modifier).clip(shape = RoundedCornerShape(8.dp)),
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
              markerStateStart.value?.let { Marker(title = "Start", state = it) }
              markerStateEnd.value?.let { Marker(title = "Ziel", state = it) }
            }
      }

  // Move camera when positions & map size are available
  LaunchedEffect(markerPositionStart, markerPositionEnd, mapSize.value) {
    if (markerPositionStart != null && markerPositionEnd != null && mapSize.value.width > 0) {
      val bounds =
          LatLngBounds.builder().include(markerPositionStart).include(markerPositionEnd).build()

      val width = mapSize.value.width
      val height = mapSize.value.height
      val padding = (height * 0.2).toInt() // 20% of height as padding

      cameraPositionState.animate(
          update = CameraUpdateFactory.newLatLngBounds(bounds, width, height, padding),
          durationMs = 1000)
    }
  }
}
