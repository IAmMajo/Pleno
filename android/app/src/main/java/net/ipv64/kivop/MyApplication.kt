package net.ipv64.kivop

import android.app.Application
import net.ipv64.kivop.services.AuthController
import net.ipv64.kivop.services.StringProvider

class MyApplication : Application() {
  lateinit var authController: AuthController

  override fun onCreate() {
    super.onCreate()
    StringProvider.initialize(applicationContext)
    authController = AuthController(applicationContext)
  }

  companion object {
    @JvmStatic
    lateinit var instance: MyApplication
      private set
  }

  init {
    instance = this
  }
}
