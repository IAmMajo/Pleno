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

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultsDTO
import net.ipv64.kivop.services.api.getPollByIDApi
import net.ipv64.kivop.services.api.getPollResultByIDApi

class PollResultViewModel(private val pollID: String) : ViewModel() {
  var poll by mutableStateOf<GetPollDTO?>(null)
  var pollResults by mutableStateOf<GetPollResultsDTO?>(null)

  private fun fetchPollData() {
    viewModelScope.launch { poll = getPollByIDApi(pollID) }
  }

  private fun fetchPollResults() {
    viewModelScope.launch { pollResults = getPollResultByIDApi(pollID) }
  }

  init {
    fetchPollData()
    fetchPollResults()
  }
}

// construct viewModel
class PollResultViewModelFactory(private val pollID: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(PollResultViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return PollResultViewModel(pollID) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
