package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollDTO
import net.ipv64.kivop.services.api.getPollsApi

class PollsListViewModel() : ViewModel() {
  var pollsList by mutableStateOf<List<GetPollDTO?>>(emptyList())

  fun fetchPoll() {
    viewModelScope.launch {
      val response = getPollsApi()
      response?.let { pollsList = it }
    }
  }

  init {
    fetchPoll()
  }
}
