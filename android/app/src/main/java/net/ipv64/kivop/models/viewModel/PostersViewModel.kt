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
import androidx.lifecycle.viewModelScope
import java.util.UUID
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterSummaryResponseDTO
import net.ipv64.kivop.services.api.getPosterImage
import net.ipv64.kivop.services.api.getPosterSummaryByIDApi
import net.ipv64.kivop.services.api.getPostersApi

class PostersViewModel : ViewModel() {
  var posters by mutableStateOf<List<PosterResponseDTO?>>(emptyList())
  var posterImages by mutableStateOf<Map<UUID, String?>>(emptyMap())
  var posterSummaries by mutableStateOf<Map<UUID, PosterSummaryResponseDTO?>>(emptyMap())

  var isLoading by mutableStateOf(true)

  fun fetchPosters() {
    viewModelScope.launch {
      isLoading = true
      try {
        val response = getPostersApi() // Call the API service to get user profile
        response.let { posters = it } // Set the user profile in ViewModel state
        response.forEach { poster ->
          poster.id.let { id ->
            viewModelScope.launch {
              val imageUrl = fetchPosterImage(id)
              val summary = fetchSummary(id)
              posterImages = posterImages + (id to imageUrl) // Update state incrementally
              posterSummaries = posterSummaries + (id to summary)
            }
          }
        }
        Log.i("PostersViewModel", "fetchPosters: $response")
      } catch (e: Exception) {
        Log.i("PostersViewModel", "fetchPosters: $e")
      } finally {
        isLoading = false
      }
    }
  }

  private suspend fun fetchPosterImage(posterId: UUID): String? {
    return try {
      getPosterImage(posterId.toString())
    } catch (e: Exception) {
      Log.e("PostersViewModel", "Error fetching image for $posterId: $e")
      null
    }
  }

  private suspend fun fetchSummary(posterId: UUID): PosterSummaryResponseDTO? {
    return try {
      getPosterSummaryByIDApi(posterId.toString())
    } catch (e: Exception) {
      Log.e("PostersViewModel", "Error fetching summary for $posterId: $e")
      null
    }
  }

  init {
    fetchPosters()
  }
}
