// MIT No Attribution
//
// Copyright 2025 KIVoP
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this
// software and associated documentation files (the Software), to deal in the Software
// without restriction, including without limitation the rights to use, copy, modify,
// merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
// INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import java.time.LocalDateTime
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.RideServiceDTOs.CreateSpecialRideDTO
import net.ipv64.kivop.services.api.postCarpoolApi

class CreateSpecialRideViewModel : ViewModel() {
  var createRideDTO by
      mutableStateOf<CreateSpecialRideDTO?>(
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
              emptySeats = 2.toUByte()))
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

  suspend fun postRide(): Boolean {
    return withContext(Dispatchers.IO) {
      val result =
          postCarpoolApi(
              CreateSpecialRideDTO(
                  name,
                  description,
                  vehicleDescription,
                  starts,
                  ends,
                  startLatitude!!,
                  startLongitude!!,
                  destinationLatitude!!,
                  destinationLongitude!!,
                  emptySeats!!))
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
