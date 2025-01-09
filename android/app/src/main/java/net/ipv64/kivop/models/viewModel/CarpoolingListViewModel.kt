package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.models.GetSpecialRideDTO
import net.ipv64.kivop.services.api.getCarpoolingListApi

class CarpoolingListViewModel: ViewModel() {
  var CarpoolingList by mutableStateOf<List<GetSpecialRideDTO?>>(emptyList())
  
  fun fetchCarpoolingList() {
    viewModelScope.launch {
      val response = getCarpoolingListApi()
      response.let { 
        // Only set list when its a different list
        if (it != CarpoolingList){
          CarpoolingList = it
          Log.i("CarpoolingViewModel", "fetchCarpoolingList: $it")
        }
      }
    }
  }

  init {
    fetchCarpoolingList()
  }
}