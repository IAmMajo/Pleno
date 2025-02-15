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

package net.ipv64.kivop.models

import android.util.Log
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingOptionDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultDTO
import net.ipv64.kivop.dtos.MeetingServiceDTOs.GetVotingResultsDTO
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okio.ByteString

suspend fun getVotings(meetingId: String): List<GetVotingDTO> =
    withContext(Dispatchers.IO) {
      val path = "meetings/$meetingId/votings"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetVotingDTO>()
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val votingsArray = Gson().fromJson(responseBody, JsonArray::class.java)
            votingsArray.map { element ->
              val voting = element.asJsonObject
              val id = voting.get("id").asString.let { UUID.fromString(it) }
              val meetingId = voting.get("meetingId").asString.let { UUID.fromString(it) }
              val question = voting.get("question").asString
              val description = voting.get("description").asString
              val isOpen = voting.get("isOpen").asBoolean
              val startedAt = voting.get("startedAt")?.asString?.let { stringToLocalDateTime(it) }
              val closedAt = voting.get("closedAt")?.asString?.let { stringToLocalDateTime(it) }
              val anonymous = voting.get("anonymous").asBoolean
              val optionsArray = voting.get("options").asJsonArray
              val iVoted = voting.get("iVoted").asBoolean
              val options =
                  optionsArray.map { option ->
                    val optionObject = option.asJsonObject
                    GetVotingOptionDTO(
                        index = optionObject.get("index").asInt.toUByte(),
                        text = optionObject.get("text").asString)
                  }

              GetVotingDTO(
                  id,
                  meetingId,
                  question,
                  description,
                  isOpen,
                  startedAt,
                  closedAt,
                  anonymous,
                  iVoted,
                  options)
            }
          } else {
            println("Fehler: Leere Antwort erhalten.")
            emptyList()
          }
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          emptyList()
        }
      } catch (e: Exception) {
        Log.e("get", "Fehler: ${e.message}")
        emptyList()
      }
    }

suspend fun GetVotingResultByID(id: String): GetVotingResultsDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/votings/$id/results"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val votingResult = Gson().fromJson(responseBody, JsonObject::class.java)
            val votingId = votingResult.get("votingId").asString.let { UUID.fromString(it) }
            val myVote = votingResult.get("myVote")?.asInt?.toUByte() // Handle nullable "myVote"
            val totalCount = votingResult.get("totalCount").asInt.toUInt()
            val resultsArray = votingResult.getAsJsonArray("results")

            val results =
                resultsArray.map { element ->
                  val resultObject = element.asJsonObject
                  val identitiesArray =
                      resultObject.getAsJsonArray("identities")?.map { identityElement ->
                        val identityObject = identityElement.asJsonObject
                        GetIdentityDTO(
                            id = UUID.fromString(identityObject.get("id").asString),
                            name = identityObject.get("name").asString)
                      }

                  GetVotingResultDTO(
                      index = resultObject.get("index").asInt.toUByte(),
                      count = resultObject.get("count").asInt.toUInt(),
                      percentage = resultObject.get("percentage").asDouble,
                      identities = identitiesArray)
                }
            GetVotingResultsDTO(
                votingId = votingId, myVote = myVote, totalCount = totalCount, results = results)
          } else {
            println("Fehler: Leere Antwort erhalten.")
            null
          }
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          null
        }
      } catch (e: Exception) {
        Log.e("get", "Fehler: ${e.message}")
        null
      }
    }

suspend fun GetVotingByID(ID: String): GetVotingDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/votings/$ID"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val voting = Gson().fromJson(responseBody, JsonObject::class.java)
            val votingJson = voting.asJsonObject
            val id = votingJson.get("id").asString.let { UUID.fromString(it) }
            val meetingId = votingJson.get("meetingId").asString.let { UUID.fromString(it) }
            val question = votingJson.get("question").asString
            val description = votingJson.get("description").asString
            val isOpen = votingJson.get("isOpen").asBoolean
            val startedAt = votingJson.get("startedAt")?.asString?.let { stringToLocalDateTime(it) }
            val closedAt = votingJson.get("closedAt")?.asString?.let { stringToLocalDateTime(it) }
            val anonymous = votingJson.get("anonymous").asBoolean
            val optionsArray = votingJson.get("options").asJsonArray
            val iVoted = votingJson.get("iVoted").asBoolean
            val options =
                optionsArray.map { option ->
                  val optionObject = option.asJsonObject
                  GetVotingOptionDTO(
                      index = optionObject.get("index").asInt.toUByte(),
                      text = optionObject.get("text").asString)
                }

            GetVotingDTO(
                id,
                meetingId,
                question,
                description,
                isOpen,
                startedAt,
                closedAt,
                anonymous,
                iVoted,
                options)
          } else {
            println("Fehler: Leere Antwort erhalten.")
            null
          }
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          null
        }
      } catch (e: Exception) {
        Log.e("get", "Fehler: ${e.message}")
        null
      }
    }

suspend fun putVote(votingId: String, optionIndex: Int): Boolean =
    withContext(Dispatchers.IO) {
      val path = "meetings/votings/$votingId/vote/$optionIndex"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext false
      }

      val emptyBody = ByteArray(0).toRequestBody(null)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .put(emptyBody)
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          true
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          false
        }
      } catch (e: Exception) {
        Log.e("put", "Fehler: ${e.message}")
        false
      }
    }

suspend fun getMyVote(ID: UUID): GetMyVoteDTO? =
    withContext(Dispatchers.IO) {
      val path = "meetings/votings/$ID/my-vote"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .get()
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val vote = Gson().fromJson(responseBody, JsonObject::class.java)
            val voteJson = vote.asJsonObject
            val index = voteJson.get("index").asInt
            val text = voteJson.get("text").asString

            GetMyVoteDTO(index, text)
          } else {
            println("Fehler: Leere Antwort erhalten.")
            null
          }
        } else {
          println("Fehler bei der Anfrage: ${response.message}")
          null
        }
      } catch (e: Exception) {
        Log.e("get", "Fehler: ${e.message}")
        null
      }
    }

class VotingWebSocketClient(
    private val votingId: UUID,
    private val listener: VotingWebSocketListener
) : WebSocketListener() {

  private var webSocket: WebSocket? = null

  suspend fun connect() {
    val token = auth.getSessionToken()
    if (token.isNullOrEmpty()) {
      Log.e("WebSocket", "Fehler: Kein Token verfügbar")
      return
    }

    val url = "$BASE_URL/meetings/votings/$votingId/live-status"
    val request = Request.Builder().url(url).addHeader("Authorization", "Bearer $token").build()

    webSocket = okHttpClient.newWebSocket(request, this)
    Log.d("WebSocket", "Verbindung zu $url wird hergestellt...")
  }

  fun disconnect() {
    webSocket?.close(1000, "Client disconnected")
  }

  override fun onOpen(webSocket: WebSocket, response: Response) {
    Log.d("WebSocket", "Verbunden mit WebSocket")
  }

  override fun onMessage(webSocket: WebSocket, text: String) {
    Log.d("WebSocket", "Empfangen: $text")
    try {
      val votingStatus = Gson().fromJson(text, GetVotingDTO::class.java)
      listener.onVotingStatusUpdate(votingStatus)
    } catch (e: Exception) {
      Log.e("WebSocket", "Fehler beim Parsen der Nachricht: ${e.message}")
    }
  }

  override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
    Log.d("WebSocket", "Empfangene Bytes: ${bytes.hex()}")
  }

  override fun onClosing(webSocket: WebSocket, code: Int, reason: String) {
    Log.d("WebSocket", "WebSocket wird geschlossen: $code / $reason")
    webSocket.close(1000, null)
  }

  override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
    Log.e("WebSocket", "Fehler: ${t.message}")
  }
}

interface VotingWebSocketListener {
  fun onVotingStatusUpdate(voting: GetVotingDTO)
}
