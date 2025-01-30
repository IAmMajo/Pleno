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
