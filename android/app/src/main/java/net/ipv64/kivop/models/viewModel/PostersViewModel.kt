package net.ipv64.kivop.models.viewModel

import android.content.Context
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.R
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.PosterServiceDTOs.PosterResponseDTO
import net.ipv64.kivop.models.PosterNeedDTO
import net.ipv64.kivop.services.StringProvider.getString
import net.ipv64.kivop.services.api.getMeetingsApi
import java.time.LocalDateTime
import java.util.UUID

class PostersViewModel: ViewModel() {
  var posters by mutableStateOf<List<PosterNeedDTO?>>(emptyList())

  fun loadMeetings(): List<PosterNeedDTO?> {
    return posters
  }
  //TODO: implement fetchPosters api
//  fun fetchPosters() {
//    viewModelScope.launch {
//      val response = getPostersApi() // Call the API service to get user profile
//      response.let { posters = it } // Set the user profile in ViewModel state
//    }
//  }
  val test1 = PosterNeedDTO(
    id = "123e4567-e89b-12d3-a456-426614174001".let { UUID.fromString(it) },
    name = "Test",
    description = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam volu",
    imageBase64 = getString(R.raw.raw),
    removeDate = LocalDateTime.now(),
    
    needHangedPosters = 2,
    hangedPosters = 31,
    tokenDownPosters = 9,
    lat = 52.520008,
    lon = 34.230023,
  )
  val test2 = PosterNeedDTO(
    id = "123e4567-e89b-12d3-a456-426614174002".let { UUID.fromString(it) },
    name = "Test2",
    description = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam volu",
    imageBase64 = getString(R.raw.raw),
    removeDate = LocalDateTime.now(),
    
    needHangedPosters = 0,
    hangedPosters = 4,
    tokenDownPosters = 1,
    lat = 52.520008,
    lon = 34.230023,
  )
  
  init {
    posters = listOf(test1, test2)
  }
}
