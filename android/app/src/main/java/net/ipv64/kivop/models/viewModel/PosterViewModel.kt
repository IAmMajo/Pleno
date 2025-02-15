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

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import java.util.UUID
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterPositionStatus
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.models.Address
import net.ipv64.kivop.services.api.OpenCageGeocoder.getAddressFromLatLngApi
import net.ipv64.kivop.services.api.getPosterByIDApi
import net.ipv64.kivop.services.api.getPosterImage
import net.ipv64.kivop.services.api.getPosterLocationsByIDApi
import net.ipv64.kivop.services.api.getPosterPositionImage
import net.ipv64.kivop.services.api.getPosterSummaryByIDApi

class PosterViewModel(private val posterId: String) : ViewModel() {
  var poster by mutableStateOf<PosterResponseDTO?>(null)
  var posterImage by mutableStateOf<String?>(null)
  var posterSummary by mutableStateOf<PosterSummaryResponseDTO?>(null)
  var posterPositions by mutableStateOf<List<PosterPositionResponseDTO>>(emptyList())
  var posterPositionsImages by mutableStateOf<Map<UUID, String?>>(emptyMap())
  var posterAddresses by mutableStateOf<Map<UUID, String>>(emptyMap())

  var isLoading by mutableStateOf(true)
  // order for sorting
  val statusOrder =
      listOf(
          PosterPositionStatus.overdue,
          PosterPositionStatus.damaged,
          PosterPositionStatus.toHang,
          PosterPositionStatus.hangs,
          PosterPositionStatus.takenDown)
  // Grouped and sorted
  val groupedPosters: Map<PosterPositionStatus, List<PosterPositionResponseDTO>>
    get() = posterPositions.sortedBy { statusOrder.indexOf(it.status) }.groupBy { it.status }

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
        posterPositions.forEach { poster ->
          poster.id.let { id ->
            viewModelScope.launch {
              val imageUrl = fetchPosterPositionImage(id)
              posterPositionsImages = posterPositionsImages + (id to imageUrl)
            }
          }
        }
      } catch (e: Exception) {
        Log.i("PosterViewModel", "fetchPosters: $e")
      } finally {
        isLoading = false
      }
    }
  }

  private fun fetchPosterImage() {
    viewModelScope.launch { posterImage = getPosterImage(posterId) }
  }

  private suspend fun fetchPosterPositionImage(posterId: UUID): String? {
    return try {
      getPosterPositionImage(posterId.toString())
    } catch (e: Exception) {
      Log.e("PostersViewModel", "Error fetching image for $posterId: $e")
      null
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
    fetchPosterImage()
  }
}

// construct viewModel
class PosterViewModelFactory(private val id: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(PosterViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return PosterViewModel(id) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
