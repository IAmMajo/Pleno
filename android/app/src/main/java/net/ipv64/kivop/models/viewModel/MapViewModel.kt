package net.ipv64.kivop.models.viewModel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import net.ipv64.kivop.services.api.OpenCageGeocoder
import net.ipv64.kivop.services.getCurrentLocation
import org.osmdroid.util.GeoPoint

class MapViewModel : ViewModel() {
  var startCoordinates by mutableStateOf<GeoPoint?>(null)
  var destinationCoordinates by mutableStateOf<GeoPoint?>(null)
  var startAddress by mutableStateOf("")
  var destinationAddress by mutableStateOf("")
  var currentLocation: GeoPoint? = null

  fun fetchStartCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(startAddress)
      if (result != null) startCoordinates = GeoPoint(result.first, result.second)
    }
  }

  fun fetchDestinationCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(destinationAddress)
      if (result != null) destinationCoordinates = GeoPoint(result.first, result.second)
    }
  }

  fun fetchCurrentLocation(context: Context) {
    viewModelScope.launch(Dispatchers.IO) {
      getCurrentLocation(
          context,
          onLocationReceived = {
            if (it != null) {
              currentLocation = GeoPoint(it.latitude, it.longitude)
              Log.d("MapViewModel", "Current location: ${it.latitude}, ${it.longitude}")
            }
          })
    }
  }
}
