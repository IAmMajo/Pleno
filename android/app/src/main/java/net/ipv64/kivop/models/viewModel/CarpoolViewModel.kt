package net.ipv64.kivop.models.viewModel

import android.content.Context
import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.bumptech.glide.Glide.init
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.RideServiceDTOs.GetRiderDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.GetSpecialRideDetailDTO
import net.ipv64.kivop.models.Address
import net.ipv64.kivop.services.api.OpenCageGeocoder
import net.ipv64.kivop.services.api.OpenCageGeocoder.getAddressFromLatLngApi
import net.ipv64.kivop.services.api.deleteRiderRequest
import net.ipv64.kivop.services.api.getCarpoolApi
import net.ipv64.kivop.services.api.patchAcceptRiderRequest
import net.ipv64.kivop.services.api.postRequestSpecialRideApi
import net.ipv64.kivop.services.getCurrentLocation
import org.osmdroid.util.GeoPoint
import java.util.UUID

class CarpoolViewModel(private val carpoolId: String) : ViewModel() {
  var carpool by mutableStateOf<GetSpecialRideDetailDTO?>(null)
  var ridersSize by mutableIntStateOf(0)
  var riderAddresses by mutableStateOf<Map<UUID, String>>(emptyMap()) 
  var me by mutableStateOf<GetRiderDTO?>(null)
  
  var startAddress by mutableStateOf<Address?>(Address("Road", "Address", "City", "Postcode"))
  var destinationAddress by mutableStateOf<Address?>(Address("Road", "Address", "City", "Postcode"))
  
  var addressInputField by mutableStateOf("")
  var myLocation by mutableStateOf<Pair<Double,Double>?>(null)
  
  fun calcRidersSize() {
    ridersSize = carpool?.riders?.count { it.accepted } ?: 0
  }
  fun canAcceptMoreRiders(): Boolean {
    return ridersSize < (carpool?.emptySeats?.toInt() ?: 0)
  }
  
  fun fetchCarpool() {
    viewModelScope.launch {
      val response = getCarpoolApi(carpoolId)
      response?.let {
        val sortedRiders = it.riders.sortedByDescending { rider -> rider.accepted }
        carpool = it.copy(riders = sortedRiders)
        fetchAddress()
        me = carpool?.riders?.find { rider -> rider.itsMe }
      }
    }
  }
  
  suspend fun postRequest(): Boolean? {
    if (me == null) {
      me = GetRiderDTO(
        id = UUID.randomUUID(),
        username = "New Rider",
        latitude = 1.0f,
        longitude = 1.0f,
        accepted = false,
        itsMe = true
      )
    }
    return myLocation?.let { postRequestSpecialRideApi(carpoolId, it) }
  }
  
  suspend fun patchAcceptRequest(riderId: UUID, accepted: Boolean): Boolean {
    return patchAcceptRiderRequest(riderId.toString(), accepted)
  }
  
  suspend fun deleteRequest(riderId: UUID): Boolean {
    return deleteRiderRequest(riderId.toString())
  }

  suspend fun fetchAddress(lat: Double, long: Double): String? {
    val addressResponse = getAddressFromLatLngApi(lat, long)
    addressResponse?.let {
      val address = Address(
        road = it.road ?: "",
        houseNumber = it.houseNumber ?: "",
        city = it.city ?: "",
        postcode = it.postcode ?: ""
      )
      return "${address.road} ${address.houseNumber}, ${address.postcode} ${address.city}"
    }
    return null
  }
  
  fun fetchAddress() {
    viewModelScope.launch {
      val startAddressResponse = getAddressFromLatLngApi(carpool!!.startLatitude.toDouble(), carpool!!.startLongitude.toDouble())
      startAddressResponse?.let {
        startAddress = Address(
          road = it.road ?: "",
          houseNumber = it.houseNumber ?: "",
          city = it.city ?: "",
          postcode = it.postcode ?: ""
        )
      }
      val destinationAddressResponse = getAddressFromLatLngApi(carpool!!.destinationLatitude.toDouble(), carpool!!.destinationLongitude.toDouble())
      destinationAddressResponse?.let {
        destinationAddress = Address(
          road = it.road ?: "",
          houseNumber = it.houseNumber ?: "",
          city = it.city ?: "",
          postcode = it.postcode ?: ""
        )
      }
    }
  }
  fun fetchCoordinates() {
    viewModelScope.launch(Dispatchers.IO) {
      val result = OpenCageGeocoder.getCoordinates(addressInputField)
      if (result != null)
        myLocation = result
    }
  }
  fun fetchCurrentLocation(context: Context) {
    viewModelScope.launch(Dispatchers.IO) {
      getCurrentLocation(
        context,
        onLocationReceived = {
          if (it != null) {
            myLocation = Pair(it.latitude, it.longitude)
            fetchAddressPopup(it.latitude, it.longitude)
          }
        }
      )
    }
  }
  fun fetchAddressPopup(lat: Double, long: Double) {
    viewModelScope.launch {
      val startAddressResponse = getAddressFromLatLngApi(lat, long)
      startAddressResponse?.let {
        addressInputField = it.road + " " + it.houseNumber
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
