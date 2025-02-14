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

package net.ipv64.kivop.services.api

import android.util.Log
import com.example.kivopandriod.services.stringToLocalDateTime
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.time.format.DateTimeFormatter
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.dtos.PollServiceDTOs.CreatePollDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetIdentityDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollResultsDTO
import net.ipv64.kivop.dtos.PollServiceDTOs.GetPollVotingOptionDTO
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.auth
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.Request
import okhttp3.RequestBody.Companion.toRequestBody

suspend fun getPollsApi(): List<GetPollDTO> =
    withContext(Dispatchers.IO) {
      val path = "polls"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetPollDTO>()
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
            val pollsArray = Gson().fromJson(responseBody, JsonArray::class.java)
            pollsArray.map { element ->
              val poll = element.asJsonObject
              val id = poll.get("id").asString.let { UUID.fromString(it) }
              val question = poll.get("question").asString
              val description = poll.get("description").asString
              val isOpen = poll.get("isOpen").asBoolean
              val startedAt = poll.get("startedAt").asString.let { stringToLocalDateTime(it) }
              val closedAt = poll.get("closedAt").asString.let { stringToLocalDateTime(it) }
              val anonymous = poll.get("anonymous").asBoolean
              val iVoted = poll.get("iVoted").asBoolean
              val multiSelect = poll.get("multiSelect").asBoolean
              val optionsArray = poll.get("options").asJsonArray
              val options =
                  optionsArray.map { option ->
                    val optionObject = option.asJsonObject
                    GetPollVotingOptionDTO(
                        index = optionObject.get("index").asInt.toUByte(),
                        text = optionObject.get("text").asString)
                  }

              GetPollDTO(
                  id,
                  question,
                  description,
                  startedAt,
                  closedAt,
                  anonymous,
                  multiSelect,
                  iVoted,
                  isOpen,
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

suspend fun getPollByIDApi(pollID: String): GetPollDTO? =
    withContext(Dispatchers.IO) {
      val path = "polls/$pollID"

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
            val poll = Gson().fromJson(responseBody, JsonObject::class.java)
            val pollJson = poll.asJsonObject
            val id = pollJson.get("id").asString.let { UUID.fromString(it) }
            val question = pollJson.get("question").asString
            val description = pollJson.get("description").asString
            val isOpen = pollJson.get("isOpen").asBoolean
            val startedAt = pollJson.get("startedAt").asString.let { stringToLocalDateTime(it) }
            val closedAt = pollJson.get("closedAt").asString.let { stringToLocalDateTime(it) }
            val anonymous = pollJson.get("anonymous").asBoolean
            val optionsArray = pollJson.get("options").asJsonArray
            val iVoted = pollJson.get("iVoted").asBoolean
            val multiSelect = pollJson.get("multiSelect").asBoolean
            val options =
                optionsArray.map { option ->
                  val optionObject = option.asJsonObject
                  GetPollVotingOptionDTO(
                      index = optionObject.get("index").asInt.toUByte(),
                      text = optionObject.get("text").asString)
                }

            GetPollDTO(
                id,
                question,
                description,
                startedAt,
                closedAt,
                anonymous,
                multiSelect,
                iVoted,
                isOpen,
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

suspend fun putPollVoteApi(pollID: String, optionIndex: Int): Boolean =
    withContext(Dispatchers.IO) {
      val path = "polls/$pollID/vote/$optionIndex"

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

suspend fun getPollResultByIDApi(id: String): GetPollResultsDTO? =
    withContext(Dispatchers.IO) {
      val path = "polls/$id/results"

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
            val totalCount = votingResult.get("totalCount").asInt.toUInt()
            val identityCount = votingResult.get("identityCount").asInt.toUInt()
            val resultsArray = votingResult.getAsJsonArray("results")
            val myVotes =
                votingResult.getAsJsonArray("myVotes").map { myVote ->
                  val identityObject = myVote.asJsonObject
                  identityObject.get("id").asInt.let { it.toUByte() }
                }
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

                  GetPollResultDTO(
                      index = resultObject.get("index").asInt.toUByte(),
                      text = resultObject.get("text").asString,
                      count = resultObject.get("count").asInt.toUInt(),
                      percentage = resultObject.get("percentage").asDouble,
                      identities = identitiesArray)
                }
            GetPollResultsDTO(
                myVotes = myVotes,
                totalCount = totalCount,
                identityCount = identityCount,
                results = results)
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

suspend fun postPollApi(createPollDTO: CreatePollDTO): Boolean =
    withContext(Dispatchers.IO) {
      val path = "polls"
      val token = auth.getSessionToken()

      val formatter = DateTimeFormatter.ISO_LOCAL_DATE_TIME
      val jsonMap =
          mutableMapOf(
              "question" to createPollDTO.question,
              "closedAt" to createPollDTO.closedAt.format(formatter) + "Z",
              "anonymous" to createPollDTO.anonymous,
              "multiSelect" to createPollDTO.multiSelect,
              "options" to createPollDTO.options)
      createPollDTO.description?.takeIf { it.isNotBlank() }?.let { jsonMap["description"] = it }

      val jsonBody = Gson().toJson(jsonMap)

      val request =
          Request.Builder()
              .url(BASE_URL + path)
              .addHeader("Authorization", "Bearer $token")
              .post(jsonBody.toRequestBody("application/json".toMediaTypeOrNull()))
              .build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        response.isSuccessful
      } catch (e: Exception) {
        println("Error: ${e.message}")
        false
      }
    }
