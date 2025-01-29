package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.bumptech.glide.Glide.init
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.models.Address
import net.ipv64.kivop.services.api.OpenCageGeocoder.getAddressFromLatLngApi
import net.ipv64.kivop.services.api.getPosterByIDApi
import net.ipv64.kivop.services.api.getPosterLocationsByIDApi
import net.ipv64.kivop.services.api.getPosterSummaryByIDApi
import java.util.UUID

class PosterViewModel(private val posterId: String): ViewModel() {
  var poster by mutableStateOf<PosterResponseDTO?>(null)
  var posterSummary by mutableStateOf<PosterSummaryResponseDTO?>(null)
  var posterPositions by mutableStateOf<List<PosterPositionResponseDTO>>(emptyList())
  var posterAddresses by mutableStateOf<Map<UUID, String>>(emptyMap())

  var isLoading by mutableStateOf(true)
  

  fun fetchPosterData() {
    viewModelScope.launch {
      isLoading = true
      try {
        // Run API calls concurrently
        val posterDeferred = async { getPosterByIDApi(posterId) }
        val summaryDeferred = async { getPosterSummaryByIDApi(posterId) }
        val positionsDeferred = async { getPosterLocationsByIDApi(posterId) }
        
        poster = posterDeferred.await()
        posterSummary = summaryDeferred.await()
        posterPositions = positionsDeferred.await()

      } catch (e: Exception) {
        Log.i("PosterViewModel", "fetchPosters: $e")
      } finally {
        isLoading = false
      }
    }
  }

  suspend fun fetchAddress(lat: Double, long: Double): String? {
    val addressResponse = getAddressFromLatLngApi(lat, long)
    addressResponse?.let {
      val address =
        Address(
          road = it.road ?: "",
          houseNumber = it.houseNumber ?: "",
          city = it.city ?: "",
          postcode = it.postcode ?: "")
      return "${address.road} ${address.houseNumber}, ${address.postcode} ${address.city}"
    }
    return null
  }
  
  init {
    fetchPosterData()
    
  }
}
//construct viewModel
class PosterViewModelFactory(private val id: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(PosterViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return PosterViewModel(id) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}