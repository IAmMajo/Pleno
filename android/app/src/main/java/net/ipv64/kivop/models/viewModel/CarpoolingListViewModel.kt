package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.RideServiceDTOs.GetSpecialRideDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.UsersRideState
import net.ipv64.kivop.services.api.getCarpoolingListApi

class CarpoolingListViewModel : ViewModel() {
  //Only rides where the logged user is the driver
  var driverRidesList by mutableStateOf<List<GetSpecialRideDTO?>>(emptyList())
  //Other rides
  var otherRidesList by mutableStateOf<List<GetSpecialRideDTO?>>(emptyList())
  
  fun fetchCarpoolingList() {
    viewModelScope.launch {
      val response = getCarpoolingListApi()
      response.let {
        // Filter rides for drivers
        driverRidesList = it.filter { ride -> ride.myState == UsersRideState.driver}
        // Filter rides for other statuses
        otherRidesList = it.filter { ride -> ride.myState != UsersRideState.driver }
      }
    }
  }

  init {
    fetchCarpoolingList()
  }
}
