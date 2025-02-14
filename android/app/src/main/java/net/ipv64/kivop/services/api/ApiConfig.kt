package net.ipv64.kivop.services.api

import net.ipv64.kivop.pages.MyApplication
import net.ipv64.kivop.services.AuthController
import okhttp3.OkHttpClient

object ApiConfig {
  //HTTP-Client für API-Anfragen.
  val okHttpClient: OkHttpClient by lazy { OkHttpClient() }
  //Basis-URL für API-Anfragen.
  const val BASE_URL = "https://kivop.ipv64.net/"
  //Authentifizierungscontroller für API-Anfragen.
  val auth = AuthController(MyApplication.instance)
}
