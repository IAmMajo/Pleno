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
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollDTO
import net.ipv64.kivop.services.api.getPollByIDApi
import net.ipv64.kivop.services.api.putPollVoteApi


class PollViewModel(private val pollID: String) : ViewModel() {
  var poll by mutableStateOf<GetPollDTO?>(null)
  var votedIndex by mutableStateOf(-1)

  fun fetchPoll() {
    viewModelScope.launch {
      val response = getPollByIDApi(pollID)
      response?.let {
        poll = it
      }
    }
  }
  
  suspend fun putPollVote(optionIndex: Int): Boolean {
    return putPollVoteApi(pollID, optionIndex)
  }

  init {
    fetchPoll()
  }
}

// construct viewModel
class PollViewModelFactory(private val PoolID: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(PollViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return PollViewModel(PoolID) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
