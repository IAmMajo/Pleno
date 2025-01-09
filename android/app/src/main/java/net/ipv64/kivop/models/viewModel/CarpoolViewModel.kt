package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.models.GetSpecialRideDetailDTO
import net.ipv64.kivop.services.api.getCarpoolApi

class CarpoolViewModel(private val carpoolId: String): ViewModel() {
  var Carpool by mutableStateOf<GetSpecialRideDetailDTO?>(null)

  fun fetchCarpool() {
    viewModelScope.launch {
      val response = getCarpoolApi(carpoolId)
      response.let {
        Carpool = it
      }
    }
  }

  init {
    fetchCarpool()
  }
}

class CarpoolViewModelFactory(private val id: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(CarpoolViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return CarpoolViewModel(id) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}