package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetRecordDTO
import net.ipv64.kivop.services.api.getProtocolApi

class ProtocolViewModel(private val meetingid: String, private val protocollang: String) :
    ViewModel() {
  var protocol by mutableStateOf<GetRecordDTO?>(null)

  fun fetchProtocol() {
    viewModelScope.launch {
      val response = getProtocolApi(meetingid, protocollang)
      response.let { protocol = it }
      Log.i("ProtocolViewModel", "fetchProtocol: $protocol")
    }
  }

  init {
    fetchProtocol()
  }
}

class ProtocolViewModelFactory(private val meetingid: String, private val protocollang: String) :
    ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(ProtocolViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return ProtocolViewModel(meetingid, protocollang) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
