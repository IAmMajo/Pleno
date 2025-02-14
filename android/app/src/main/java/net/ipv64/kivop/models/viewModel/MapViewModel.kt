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

package net.ipv64.kivop.models.viewModel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.maps.model.LatLng
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import net.ipv64.kivop.services.api.OpenCageGeocoder
import net.ipv64.kivop.services.getCurrentLocation

class MapViewModel : ViewModel() {
  var startCoordinates by mutableStateOf<LatLng?>(null)
  var destinationCoordinates by mutableStateOf<LatLng?>(null)
  var startAddress by mutableStateOf("")
  var destinationAddress by mutableStateOf("")
  var currentLocation: LatLng? = null

  fun fetchStartCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(startAddress)
      startCoordinates =
          if (result != null) {
            LatLng(result.first, result.second)
          } else {
            null
          }
    }
  }

  fun fetchDestinationCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(destinationAddress)
      destinationCoordinates =
          if (result != null) {
            LatLng(result.first, result.second)
          } else {
            null
          }
    }
  }

  fun fetchCurrentLocation(context: Context) {
    viewModelScope.launch(Dispatchers.IO) {
      getCurrentLocation(
          context,
          onLocationReceived = {
            if (it != null) {
              currentLocation = LatLng(it.latitude, it.longitude)
              Log.d("MapViewModel", "Current location: ${it.latitude}, ${it.longitude}")
            }
          })
    }
  }
}
