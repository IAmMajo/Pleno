package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import java.util.UUID
import kotlinx.coroutines.async
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.services.api.getPosterSummaryByIDApi
import net.ipv64.kivop.services.api.getPostersApi

class PostersViewModel : ViewModel() {
  var posters by mutableStateOf<List<PosterResponseDTO?>>(emptyList())
  var posterSummaries by mutableStateOf<Map<UUID, PosterSummaryResponseDTO?>>(emptyMap())

  var isLoading by mutableStateOf(true)

  fun fetchPosters() {
    viewModelScope.launch {
      isLoading = true
      try {
        val response = getPostersApi() // Call the API service to get user profile
        response.let { posters = it } // Set the user profile in ViewModel state
        Log.i("PostersViewModel", "fetchPosters: $response")
      } catch (e: Exception) {
        Log.i("PostersViewModel", "fetchPosters: $e")
      } finally {
        isLoading = false
        fetchSummary()
      }
    }
  }

  fun fetchSummary() {
    viewModelScope.launch {
      if (posters != null) {
        val summaries =
            posters
                .map { poster ->
                  async { poster!!.id to getPosterSummaryByIDApi(poster.id.toString()) }
                }
                .associate { it.await() }
        posterSummaries = summaries
      }
    }
  }

  init {
    fetchPosters()
  }
}
