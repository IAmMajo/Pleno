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
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import net.ipv64.kivop.services.api.ApiConfig
import okhttp3.*
import okio.ByteString

class VotingViewModel(private val votingId: String) : ViewModel() {

  private val _votingStatus = MutableStateFlow("")
  val votingStatus = _votingStatus.asStateFlow()

  private val _votingResults = MutableStateFlow(false)
  val votingResults = _votingResults.asStateFlow()

  private var webSocket: WebSocket? = null

  suspend fun connectWebSocket() {
    val token = ApiConfig.auth.getSessionToken()
    if (token.isNullOrEmpty()) {
      Log.e("WebSocket", "Fehler: Kein Token verfügbar")
      return
    }

    val url = "${ApiConfig.BASE_URL}meetings/votings/$votingId/live-status"
    val request = Request.Builder().url(url).addHeader("Authorization", "Bearer $token").build()

    webSocket =
        ApiConfig.okHttpClient.newWebSocket(
            request,
            object : WebSocketListener() {
              override fun onOpen(webSocket: WebSocket, response: Response) {
                Log.d("WebSocket", "Verbunden mit WebSocket")
              }

              override fun onMessage(webSocket: WebSocket, text: String) {
                Log.d("WebSocket", "Empfangen: $text")

                viewModelScope.launch {
                  // Check if the response contains an error message
                  if (text.startsWith("ERROR:")) {
                    // Handle error message
                    _votingStatus.emit("Fehler: ${text.substring(7)}")
                  } else if (text.contains("/")) {
                    // Handle vote count, format "n/total"
                    val voteStatus = text.trim()
                    _votingStatus.emit(voteStatus) // Emit as "n/total"
                  }
                }
              }

              override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
                val message = bytes.utf8() // Decode ByteString to UTF-8 String
                Log.d("WebSocket", "Empfangene Bytes: $message")

                try {
                  viewModelScope.launch {
                    _votingResults.emit(true) // Emit true (or any signal you'd like to use)
                  }
                } catch (e: Exception) {
                  Log.e("WebSocket", "Fehler beim Parsen der Abstimmungsergebnisse: ${e.message}")
                }
              }

              override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
                Log.d("WebSocket", "WebSocket wird geschlossen: $code / $reason")

                webSocket.close(1000, null)
              }

              override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
                Log.e("WebSocket", "Fehler: ${t.message}")
              }
            })

    Log.d("WebSocket", "Verbindung zu $url wird hergestellt...")
  }

  fun disconnectWebSocket() {
    webSocket?.close(1000, "Client disconnected")
  }

  override fun onCleared() {
    super.onCleared()
    disconnectWebSocket()
  }
}

// construct viewModel
class VotingViewModelFactory(private val votingId: String) : ViewModelProvider.Factory {
  override fun <T : ViewModel> create(modelClass: Class<T>): T {
    if (modelClass.isAssignableFrom(VotingViewModel::class.java)) {
      @Suppress("UNCHECKED_CAST")
      return VotingViewModel(votingId) as T
    }
    throw IllegalArgumentException("Unknown ViewModel class")
  }
}
