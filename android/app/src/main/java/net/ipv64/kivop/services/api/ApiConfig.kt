package net.ipv64.kivop.services.api

import net.ipv64.kivop.MyApplication
import net.ipv64.kivop.services.AuthController
import okhttp3.OkHttpClient

object ApiConfig {
  val okHttpClient: OkHttpClient by lazy { OkHttpClient() }
  const val BASE_URL = "https://kivop.ipv64.net/"
  val auth = AuthController(MyApplication.instance)
}
