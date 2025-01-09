package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.bumptech.glide.Glide.init
import kotlinx.coroutines.launch
import net.ipv64.kivop.components.ResponseItem
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetAttendanceDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.models.getVotings
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.services.api.putPlanAttendance

class MeetingViewModel(private val meetingId: String): ViewModel() {
  var meeting by mutableStateOf<GetMeetingDTO?>(null)
  var attendance by mutableStateOf<List<GetAttendanceDTO>>(emptyList())
  var votings by mutableStateOf<List<GetVotingDTO>>(emptyList())
  var you by mutableStateOf<GetAttendanceDTO?>(null)
  
  var responseItems by mutableStateOf<List<ResponseItem>>(emptyList())
  var pendingList by mutableStateOf<List<ResponseItem>>(emptyList())
  var presentList by mutableStateOf<List<ResponseItem>>(emptyList())
  var absentList by mutableStateOf<List<ResponseItem>>(emptyList())
  var acceptedList by mutableStateOf<List<ResponseItem>>(emptyList())
  var maxMembernumber by mutableStateOf(0)
  var isPendingVisible by mutableStateOf(true) 
  var isPresentVisible by  mutableStateOf(true) 
  var isAbsentVisible by  mutableStateOf(true) 
  var isAcceptedVisible by mutableStateOf(true) 
  
  fun fetchMeeting() {
    viewModelScope.launch {
      val response = getMeetingByID(meetingId)
      response.let { meeting = it }
    }
  }
  fun fetchVotings() {
    viewModelScope.launch {
      val response = getVotings(meetingId)
      response.let { votings = it }
    }
  }

  fun fetchAttendance() {
    viewModelScope.launch {
      val response = getAttendances(meetingId)
      response.let { attendance = it }
      try {
        you = response.find { it.itsame }
        responseItems = response.map {
          ResponseItem(name = it.identity.name, status = it.status)
        } 
        pendingList = responseItems.filter { it.status == null }
        presentList= responseItems.filter { it.status == AttendanceStatus.present }
        absentList = responseItems.filter { it.status == AttendanceStatus.absent }
        acceptedList = responseItems.filter { it.status == AttendanceStatus.accepted }
        maxMembernumber = response.size
      }catch (e: Exception){
        you = null
      }
    }
  }
  
  suspend fun planAttendance(status: PlanAttendance) {
    if(putPlanAttendance(meetingId, status)){
      var updatedStatus = AttendanceStatus.valueOf(status.name)
      if (status == PlanAttendance.present){
        updatedStatus = AttendanceStatus.accepted
        you = you?.copy(status = updatedStatus)
      }else{
        you = you?.copy(status = updatedStatus)
      }
      you?.let { user ->
        // Remove the user from all lists first
        responseItems = responseItems.filter { it.name != user.identity.name }

        // Add the user to the appropriate list
        val updatedItem = ResponseItem(name = user.identity.name, status = updatedStatus)
        responseItems = responseItems + updatedItem

        // Rebuild the categorized lists
        pendingList = responseItems.filter { it.status == null }
        presentList = responseItems.filter { it.status == AttendanceStatus.present }
        absentList = responseItems.filter { it.status == AttendanceStatus.absent }
        acceptedList = responseItems.filter { it.status == AttendanceStatus.accepted }
      }
    }
  }

  
  init {
    fetchMeeting()
    fetchAttendance()
    fetchVotings()
  }
}

class MeetingViewModelFactory(private val id: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(MeetingViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return MeetingViewModel(id) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}