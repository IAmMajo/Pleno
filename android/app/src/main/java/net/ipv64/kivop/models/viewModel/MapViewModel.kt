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
      if (result != null) startCoordinates = LatLng(result.first, result.second)
    }
  }

  fun fetchDestinationCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(destinationAddress)
      if (result != null) destinationCoordinates = LatLng(result.first, result.second)
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
