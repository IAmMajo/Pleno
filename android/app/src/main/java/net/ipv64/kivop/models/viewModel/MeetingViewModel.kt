package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.AttendanceStatus
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetAttendanceDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetMeetingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetRecordDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.models.PlanAttendance
import net.ipv64.kivop.models.attendancesList
import net.ipv64.kivop.models.getVotings
import net.ipv64.kivop.services.api.getAttendances
import net.ipv64.kivop.services.api.getMeetingByID
import net.ipv64.kivop.services.api.getProtocolsApi
import net.ipv64.kivop.services.api.postExtendProtocol
import net.ipv64.kivop.services.api.postGenerateSocialMediaPost
import net.ipv64.kivop.services.api.putAttend
import net.ipv64.kivop.services.api.putPlanAttendance

class MeetingViewModel(private val meetingId: String) : ViewModel() {
  var meeting by mutableStateOf<GetMeetingDTO?>(null)
  var protocols by mutableStateOf<List<GetRecordDTO>>(emptyList())

  var attendance by mutableStateOf<List<GetAttendanceDTO>>(emptyList())
  var votings by mutableStateOf<List<GetVotingDTO>>(emptyList())
  var you by mutableStateOf<GetAttendanceDTO?>(null)

  var responseItems by mutableStateOf<List<attendancesList>>(emptyList())
  var pendingList by mutableStateOf<List<attendancesList>>(emptyList())
  var presentList by mutableStateOf<List<attendancesList>>(emptyList())
  var presentListcount: Int? = null

  var absentList by mutableStateOf<List<attendancesList>>(emptyList())
  var acceptedList by mutableStateOf<List<attendancesList>>(emptyList())
  var acceptedListcound: Int? = null

  var maxMembernumber by mutableStateOf(0)
  var isPendingVisible by mutableStateOf(true)
  var isPresentVisible by mutableStateOf(true)
  var isAbsentVisible by mutableStateOf(true)
  var isAcceptedVisible by mutableStateOf(true)
  var isAttendanceVisible by mutableStateOf(false)

  // Privates StateFlow, in dem wir die Zeilen sammeln
  private val _lines = MutableStateFlow(emptyList<String>())

  // Öffentliches (Read-Only) StateFlow
  val lines = _lines.asStateFlow()

  fun clearLines() {
    _lines.value = emptyList() // Liste zurücksetzen
  }


  fun fetchMeeting() {
    viewModelScope.launch {
      val response = getMeetingByID(meetingId)
      response.let { meeting = it }
      Log.i("Meetin chik", response.toString())
    }
  }

  fun fetchProtocol() {
    viewModelScope.launch {
      val response = getProtocolsApi(meetingId)
      Log.i("protocolTTTT", response.toString())
      response.let { protocols = it }
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
        responseItems =
            response.map { attendancesList(name = it.identity.name, status = it.status) }
        pendingList = responseItems.filter { it.status == null }
        presentList = responseItems.filter { it.status == AttendanceStatus.present }
        presentListcount = presentList.size
        absentList = responseItems.filter { it.status == AttendanceStatus.absent }
        acceptedList = responseItems.filter { it.status == AttendanceStatus.accepted }
        acceptedListcound = acceptedList.size
        maxMembernumber = response.size
      } catch (e: Exception) {
        you = null
      }
    }
  }

  suspend fun planAttendance(status: PlanAttendance) {
    if (putPlanAttendance(meetingId, status)) {
      var updatedStatus = AttendanceStatus.valueOf(status.name)
      if (status == PlanAttendance.present) {
        updatedStatus = AttendanceStatus.accepted
        you = you?.copy(status = updatedStatus)
      } else {
        you = you?.copy(status = updatedStatus)
      }
      you?.let { user ->
        // Remove the user from all lists first
        responseItems = responseItems.filter { it.name != user.identity.name }

        // Add the user to the appropriate list
        val updatedItem = attendancesList(name = user.identity.name, status = updatedStatus)
        responseItems = responseItems + updatedItem

        // Rebuild the categorized lists
        pendingList = responseItems.filter { it.status == null }
        presentList = responseItems.filter { it.status == AttendanceStatus.present }
        absentList = responseItems.filter { it.status == AttendanceStatus.absent }
        acceptedList = responseItems.filter { it.status == AttendanceStatus.accepted }
      }
    }
  }

  fun startSocialMediaPost(content: String, lang: String) {
    Log.d("ProtocolStart", "startExtendProtocol called")
    viewModelScope.launch(Dispatchers.Main) {
      postGenerateSocialMediaPost(content, lang).collect { line ->
        _lines.value = _lines.value + line
        Log.d("ProtocolViewModel", "Neue Zeile: $line")
      }
    }
  }

  suspend fun attend(code: String): Boolean {
    if (putAttend(meetingId, code)) {
      var updatedStatus = AttendanceStatus.present

      you = you?.copy(status = updatedStatus)
      you?.let { user ->
        // Remove the user from all lists first
        responseItems = responseItems.filter { it.name != user.identity.name }

        // Add the user to the appropriate list
        val updatedItem = attendancesList(name = user.identity.name, status = updatedStatus)
        responseItems = responseItems + updatedItem

        // Rebuild the categorized lists
        pendingList = responseItems.filter { it.status == null }
        presentList = responseItems.filter { it.status == AttendanceStatus.present }
        absentList = responseItems.filter { it.status == AttendanceStatus.absent }
        acceptedList = responseItems.filter { it.status == AttendanceStatus.accepted }
      }
      return true
    } else {
      return false
    }
  }

  init {
    fetchMeeting()
    fetchAttendance()
    fetchProtocol()
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
