package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.services.api.getMeetingsApi

class MeetingsViewModel : ViewModel() {
  var meetings by mutableStateOf<List<GetMeetingDTO?>>(emptyList())

  fun loadMeetings(): List<GetMeetingDTO?> {
    return meetings
  }

  fun fetchMeetings() {
    viewModelScope.launch {
      val response = getMeetingsApi() // Call the API service to get user profile
      response.let { meetings = it } // Set the user profile in ViewModel state
    }
  }

  init {}
}
