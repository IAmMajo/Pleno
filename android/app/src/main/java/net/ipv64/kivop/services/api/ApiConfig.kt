package net.ipv64.kivop.services.api

import okhttp3.OkHttpClient

object ApiConfig {
  val okHttpClient: OkHttpClient by lazy {
    OkHttpClient()
  }
  const val BASE_URL = "https://kivop.ipv64.net/"
}