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

import android.util.Log
import androidx.compose.runtime.State
import androidx.compose.runtime.mutableStateOf
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetRecordDTO
import net.ipv64.kivop.services.api.getProtocolApi
import net.ipv64.kivop.services.api.patchProtocol
import net.ipv64.kivop.services.api.postExtendProtocol

class ProtocolViewModel(private val meetingId: String, private val protocolLang: String) :
    ViewModel() {
  // Internes MutableState
  private val _protocol = mutableStateOf<GetRecordDTO?>(null)

  // Extern exponierter State
  val protocol: State<GetRecordDTO?> = _protocol

  // Lokaler State für bearbeitbaren Markdown-Text
  private var _editableMarkdown = mutableStateOf("")
  var editableMarkdown: State<String> = _editableMarkdown

  // Privates StateFlow, in dem wir die Zeilen sammeln
  private val _lines = MutableStateFlow(emptyList<String>())

  // Öffentliches (Read-Only) StateFlow
  val lines = _lines.asStateFlow()

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

        patchProtocol(meetingId, protocolLang, protocol.content)

        Log.d("ProtocolViewModel2", "Gespeichert: ${protocol.content}")
      }
    }
  }

  fun startExtendProtocol(content: String, lang: String) {
    Log.d("ProtocolStart", "startExtendProtocol called")
    viewModelScope.launch(Dispatchers.Main) {
      postExtendProtocol(content, lang).collect { line ->
        _lines.value = _lines.value + line
        Log.d("ProtocolViewModel", "Neue Zeile: $line")
      }
    }
  }

  fun startSocialMediaPost(content: String, lang: String) {
    Log.d("ProtocolStart", "startExtendProtocol called")
    viewModelScope.launch(Dispatchers.Main) {
      postExtendProtocol(content, lang).collect { line ->
        _lines.value = _lines.value + line
        Log.d("ProtocolViewModel", "Neue Zeile: $line")
      }
    }
  }
}

class ProtocolViewModelFactory(
    private val meetingId: String,
    private val protocolLang: String,
) : ViewModelProvider.Factory {

  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(ProtocolViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return ProtocolViewModel(meetingId, protocolLang) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
