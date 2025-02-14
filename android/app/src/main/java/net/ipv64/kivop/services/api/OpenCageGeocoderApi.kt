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

import com.google.gson.JsonParser
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import net.ipv64.kivop.BuildConfig
import net.ipv64.kivop.models.Address
import net.ipv64.kivop.services.api.ApiConfig.okHttpClient
import okhttp3.Request
import org.json.JSONObject

object OpenCageGeocoder {
  private const val API_KEY = BuildConfig.OPENCAGE_API_KEY

  fun getCoordinates(location: String): Pair<Double, Double>? {
    val url = "https://api.opencagedata.com/geocode/v1/json?q=$location&key=$API_KEY"
    val request = Request.Builder().url(url).build()

    okHttpClient.newCall(request).execute().use { response ->
      if (!response.isSuccessful) return null

      val json = JSONObject(response.body?.string() ?: "")
      val results = json.getJSONArray("results")
      if (results.length() == 0) return null

      val geometry = results.getJSONObject(0).getJSONObject("geometry")
      return Pair(geometry.getDouble("lat"), geometry.getDouble("lng"))
    }
  }

  suspend fun getAddressFromLatLngApi(lat: Double, lng: Double): Address? =
      withContext(Dispatchers.IO) {
        val url = "https://api.opencagedata.com/geocode/v1/json?q=$lat+$lng&key=$API_KEY"
        val request = Request.Builder().url(url).build()

        okHttpClient.newCall(request).execute().use { response ->
          if (!response.isSuccessful) return@withContext null

          response.body?.string()?.let { responseBody ->
            val jsonObject = JsonParser.parseString(responseBody).asJsonObject
            val results = jsonObject.getAsJsonArray("results")

            if (results.size() > 0) {
              val components = results[0].asJsonObject.getAsJsonObject("components")
              val road = components.get("road")?.asString
              val houseNumber = components.get("house_number")?.asString
              val city = components.get("city")?.asString
              val postcode = components.get("postcode")?.asString
              return@withContext Address(road, houseNumber, city, postcode)
            } else {
              return@withContext null
            }
          }
          return@withContext null
        }
      }
}
