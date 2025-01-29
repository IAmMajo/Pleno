package net.ipv64.kivop.models.viewModel

import android.util.Log
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetRecordDTO
import net.ipv64.kivop.services.api.getProtocolApi

class ProtocolViewModel(private val meetingId: String, private val protocolLang: String) : ViewModel() {
  // Internes MutableState
  private val _protocol = mutableStateOf<GetRecordDTO?>(null)

  // Extern exponierter State
  val protocol: State<GetRecordDTO?> = _protocol

  // Lokaler State für bearbeitbaren Markdown-Text
  private val _editableMarkdown = mutableStateOf("")
  val editableMarkdown: State<String> = _editableMarkdown

  init {
    fetchProtocol()
  }

  fun fetchProtocol() {
    viewModelScope.launch {
      try {
        val response = getProtocolApi(meetingId, protocolLang)
        _protocol.value = response
        _editableMarkdown.value = response?.content ?: ""
        Log.i("ProtocolViewModel", "fetchProtocol: $protocol")
      } catch (e: Exception) {
        Log.e("ProtocolViewModel", "Fehler beim Laden des Protokolls", e)
        // Optional: Fehler-Handling, z.B. Anzeigen einer Fehlermeldung
      }
    }
  }

  fun onMarkdownChange(newContent: String) {
    _editableMarkdown.value = newContent
    Log.d("ProtocolViewModel", "Markdown geändert: $newContent")
  }

  fun saveProtocolContent() {
    viewModelScope.launch {
      _protocol.value?.let { protocol ->
        protocol.content = _editableMarkdown.value
        // Hier solltest du deinen Repository-/API-Aufruf zum Speichern durchführen
        // Beispiel: repository.updateProtocol(protocol)
        Log.d("ProtocolViewModel", "Gespeichert: ${protocol.content}")
      }
    }
  }
}

class ProtocolViewModelFactory(private val meetingId: String, private val protocolLang: String) :
  ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(ProtocolViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return ProtocolViewModel(meetingId, protocolLang) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}

