package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.RideServiceDTOs.CreateSpecialRideDTO
import net.ipv64.kivop.services.api.OpenCageGeocoder
import net.ipv64.kivop.services.api.postCarpoolApi
import org.osmdroid.util.GeoPoint
import java.time.LocalDateTime

class CreateSpecialRideViewModel: ViewModel()  {
  var createRideDTO by mutableStateOf<CreateSpecialRideDTO?>(
    CreateSpecialRideDTO(
      name = "name",
      description = null,
      vehicleDescription = null,
      starts = LocalDateTime.now(),
      ends = LocalDateTime.now(),
      startLatitude = 10f,
      startLongitude = 10f,
      destinationLatitude = 10f,
      destinationLongitude = 10f,
      emptySeats = 2.toUByte()
    )
  )
  var done by mutableStateOf(false)
  
  var name by mutableStateOf("")
  var description by mutableStateOf("")
  var vehicleDescription by mutableStateOf("")
  var starts by mutableStateOf(LocalDateTime.now())
  var ends by mutableStateOf(LocalDateTime.now())
  var emptySeats by mutableStateOf<UByte?>(null)
  var startLatitude by mutableStateOf<Float?>(null)
  var startLongitude by mutableStateOf<Float?>(null)
  var destinationLatitude by mutableStateOf<Float?>(null)
  var destinationLongitude by mutableStateOf<Float?>(null)
  
  var startAddress by mutableStateOf("")
  var destinationAddress by mutableStateOf("")
  
  suspend fun postRide():Boolean {
    return withContext(Dispatchers.IO) {
      val result = postCarpoolApi(CreateSpecialRideDTO(name, description, vehicleDescription, starts, ends, startLatitude!!, startLongitude!!, destinationLatitude!!, destinationLongitude!!, emptySeats!!))
      return@withContext result
      }
  }
  
  
//  fun fetchDestinationAddress() {
//    viewModelScope.launch(Dispatchers.IO) {
//      if (destinationLatitude != null && destinationLongitude != null) {
//        val result = OpenCageGeocoder.getAddressFromLatLng(
//          destinationLatitude.toDouble(),
//          destinationLongitude.toDouble()
//        )
//        if (result != null) {
//          destinationAddress = result
//        }
//      }
//    }
//  }
}