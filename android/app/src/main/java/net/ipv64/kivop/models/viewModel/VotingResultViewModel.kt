package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultsDTO
import net.ipv64.kivop.models.GetVotingByID
import net.ipv64.kivop.models.GetVotingResultByID


class VotingResultViewModel(private val votingId: String) : ViewModel() {
  var votingData by mutableStateOf<GetVotingDTO?>(null)
  var votingResults by mutableStateOf<GetVotingResultsDTO?>(null)
  
  private fun fetchVotingData() {
    viewModelScope.launch {
      votingData = GetVotingByID(votingId)
    }
  }
  private fun fetchVotingResults() {
    viewModelScope.launch {
      votingResults = GetVotingResultByID(votingId)
    }
  }
  init {
    fetchVotingData()
    fetchVotingResults()
  }
}

// construct viewModel
class VotingResultViewModelFactory(private val votingId: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(VotingResultViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return VotingResultViewModel(votingId) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}