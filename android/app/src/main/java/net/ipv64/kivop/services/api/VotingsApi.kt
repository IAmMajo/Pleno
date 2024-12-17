package net.ipv64.kivop.moduls

import android.content.Context
import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonArray
import com.google.gson.JsonObject
import java.util.UUID
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.services.api.ApiConfig.BASE_URL
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request

suspend fun GetVotings(context: Context): List<GetVotingDTO> =
    withContext(Dispatchers.IO) {
      var auth = AuthController(context)
      val path = "meetings/votings"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext emptyList<GetVotingDTO>()
      }

      val request =
          Request.Builder().url(BASE_URL + path).addHeader("Authorization", "Bearer $token").get().build()

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
              val startedAt = voting.get("startedAt")?.asString ?: null
              val closedAt = voting.get("closedAt")?.asString ?: null
              val anonymous = voting.get("anonymous").asBoolean
              val optionsArray = voting.get("options").asJsonArray
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

suspend fun GetVotingResultByID(context: Context, id: UUID): GetVotingResultsDTO? =
    withContext(Dispatchers.IO) {
      var auth = AuthController(context)
      val path = "meetings/votings/$id/results"
      
      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder().url(BASE_URL + path).addHeader("Authorization", "Bearer $token").get().build()

      return@withContext try {
        val response = okHttpClient.newCall(request).execute()
        if (response.isSuccessful) {
          val responseBody = response.body?.string()
          if (responseBody != null) {
            val votingResult = Gson().fromJson(responseBody, JsonObject::class.java)
            val votingId = votingResult.get("votingId").asString.let { UUID.fromString(it) }
            val myVote = votingResult.get("myVote")?.asInt?.toUByte() // Handle nullable "myVote"
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
                      total = resultObject.get("total").asInt.toUByte(),
                      percentage = resultObject.get("percentage").asDouble,
                      identities = identitiesArray)
                }
            GetVotingResultsDTO(votingId = votingId, myVote = myVote, results = results)
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

suspend fun GetVotingByID(context: Context, ID: UUID): GetVotingDTO? =
    withContext(Dispatchers.IO) {
      var auth = AuthController(context)
      val path = "meetings/votings/$ID"

      val token = auth.getSessionToken()

      if (token.isNullOrEmpty()) {
        println("Fehler: Kein Token verfügbar")
        return@withContext null
      }

      val request =
          Request.Builder().url(BASE_URL + path).addHeader("Authorization", "Bearer $token").get().build()

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
            val startedAt = votingJson.get("startedAt")?.asString ?: null
            val closedAt = votingJson.get("closedAt")?.asString ?: null
            val anonymous = votingJson.get("anonymous").asBoolean
            val optionsArray = votingJson.get("options").asJsonArray
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
