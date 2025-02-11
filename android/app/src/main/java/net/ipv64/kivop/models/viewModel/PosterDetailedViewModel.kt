package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.models.Address
import net.ipv64.kivop.services.api.OpenCageGeocoder.getAddressFromLatLngApi
import net.ipv64.kivop.services.api.getPosterLocationByIDApi
import net.ipv64.kivop.services.api.getPosterPositionImage
import net.ipv64.kivop.services.api.getProfileImage
import net.ipv64.kivop.services.api.putHangPoster
import net.ipv64.kivop.services.api.putReportDamagePoster
import net.ipv64.kivop.services.api.putTakeDownPoster

class PosterDetailedViewModel(private val posterId: String, private val locationId: String) :
    ViewModel() {
  var poster by mutableStateOf<PosterPositionResponseDTO?>(null)
  var posterImage by mutableStateOf<String?>(null)
  var posterAddress by mutableStateOf<Address?>(null)
  var userImages by mutableStateOf<Map<UUID, String?>>(emptyMap())

  var isLoading by mutableStateOf(true)

  fun fetchPosterData() {
    viewModelScope.launch {
      isLoading = true
      try {
        poster = getPosterLocationByIDApi(posterId, locationId)
        if (poster != null) {
          posterAddress = fetchAddress(poster!!.latitude, poster!!.longitude)
        }
      } catch (e: Exception) {
        Log.i("PosterViewModel", "fetchPosters: $e")
      } finally {
        isLoading = false
      }
    }
  }
  
  fun fetchPosterImage() {
    viewModelScope.launch {
      posterImage = getPosterPositionImage(locationId)
    }
  }

  suspend fun fetchAddress(lat: Double, long: Double): Address? {
    val addressResponse = getAddressFromLatLngApi(lat, long)
    addressResponse?.let {
      val address =
          Address(
              road = it.road ?: "",
              houseNumber = it.houseNumber ?: "",
              city = it.city ?: "",
              postcode = it.postcode ?: "")
      return address
    }
    return null
  }

  fun fetchUserImages() {
    poster?.responsibleUsers?.forEach { user ->
      viewModelScope.launch {
        val base64String = getProfileImage(user.id.toString())
        userImages = userImages.toMutableMap().apply { put(user.id, base64String) }
      }
    }
  }

  suspend fun hangPoster(base64: String): Boolean {
    Log.i("test", "PosterDetailedPage: $base64")
    if (putHangPoster(poster?.id.toString(), base64)) {
      posterImage = base64
      return true
    }
    return false
  }

  suspend fun takeOffPoster(base64: String): Boolean {
    Log.i("test", "PosterDetailedPage: $base64")
    if (putTakeDownPoster(poster?.id.toString(), base64)) {
      posterImage = base64
      return true
    }
    return false
  }

  suspend fun reportDamage(base64: String): Boolean {
    Log.i("test", "PosterDetailedPage: $base64")
    if (putReportDamagePoster(poster?.id.toString(), base64)) {
      posterImage = base64
      return true
    }
    return false
  }

  init {
    fetchPosterData()
    fetchPosterImage()
  }
}

// construct viewModel
class PosterDetailedViewModelFactory(private val posterId: String, private val locationId: String) :
    ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(PosterDetailedViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return PosterDetailedViewModel(posterId, locationId) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
